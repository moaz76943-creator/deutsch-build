import 'dart:math' as math;

enum EntityCategory {
  location,
  scholar,
  linguisticConcept,
  historicalMonument,
  institution,
}

enum MatchType {
  exactAlias,
  normalizedFuzzy,
  contextualDisambiguation,
}

/// Sovereign cross-lingual entity definition.
class SovereignEntity {
  final String entityId;
  final String canonicalName;
  final EntityCategory category;
  final Map<String, List<String>> multilingualAliases; // langCode -> aliases
  final Map<String, dynamic> attributes;

  const SovereignEntity({
    required this.entityId,
    required this.canonicalName,
    required this.category,
    required this.multilingualAliases,
    this.attributes = const {},
  });

  /// Flatten all aliases across all languages
  List<String> get allAliases {
    final list = <String>[canonicalName];
    for (final aliases in multilingualAliases.values) {
      list.addAll(aliases);
    }
    return list;
  }
}

/// Linked entity occurrence in running text.
class LinkedEntityMatch {
  final SovereignEntity entity;
  final String matchedText;
  final int charStart;
  final int charEnd;
  final double confidence;
  final MatchType matchType;

  const LinkedEntityMatch({
    required this.entity,
    required this.matchedText,
    required this.charStart,
    required this.charEnd,
    required this.confidence,
    required this.matchType,
  });
}

/// Sovereign on-device multilingual cross-lingual entity linker.
/// Links surface forms in any language to canonical sovereign entity IDs.
class MultilingualEntityLinkerV2 {
  final Map<String, SovereignEntity> _entities = {};
  final Map<String, Set<String>> _aliasToEntityIds = {}; // normalizedAlias -> Set of entityId

  MultilingualEntityLinkerV2();

  int get entityCount => _entities.length;

  void registerEntity(SovereignEntity entity) {
    _entities[entity.entityId] = entity;
    for (final alias in entity.allAliases) {
      final normalized = _normalizeText(alias);
      _aliasToEntityIds.putIfAbsent(normalized, () => <String>{}).add(entity.entityId);
    }
  }

  static String _normalizeText(String text) {
    return text
        .trim()
        .toLowerCase()
        // Strip Arabic diacritics / tashkeel
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        // Normalize Arabic alif
        .replaceAll(RegExp(r'[إأآ]'), 'ا')
        .replaceAll(RegExp(r'[\s\-_]+'), ' ');
  }

  /// Scans text and extracts linked entity occurrences across 100 languages.
  List<LinkedEntityMatch> linkEntities({
    required String text,
    required String languageCode,
    double minFuzzyThreshold = 0.85,
  }) {
    if (text.trim().isEmpty || _entities.isEmpty) return const [];

    final matches = <LinkedEntityMatch>[];
    final words = text.split(RegExp(r'\s+'));
    final normFullText = _normalizeText(text);

    // 1. Direct multi-word n-gram scanning (from 4-grams down to unigrams)
    for (int n = 4; n >= 1; n--) {
      for (int i = 0; i <= words.length - n; i++) {
        final phrase = words.sublist(i, i + n).join(' ');
        final cleanPhrase = phrase.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '');
        final normPhrase = _normalizeText(cleanPhrase);
        if (normPhrase.isEmpty) continue;

        // Exact alias lookup
        final entityIds = _aliasToEntityIds[normPhrase];
        if (entityIds != null && entityIds.isNotEmpty) {
          final startIdx = text.indexOf(phrase);
          final endIdx = startIdx + phrase.length;

          for (final eId in entityIds) {
            final entity = _entities[eId];
            if (entity != null) {
              matches.add(LinkedEntityMatch(
                entity: entity,
                matchedText: phrase,
                charStart: startIdx >= 0 ? startIdx : 0,
                charEnd: endIdx >= 0 ? endIdx : phrase.length,
                confidence: 1.0,
                matchType: MatchType.exactAlias,
              ));
            }
          }
        }
      }
    }

    // 2. Fuzzy fallback for close spelling variants if no exact match found
    if (matches.isEmpty) {
      for (final entry in _aliasToEntityIds.entries) {
        final alias = entry.key;
        if (alias.length < 4) continue;

        final sim = _jaroWinklerSimilarity(normFullText, alias);
        if (sim >= minFuzzyThreshold) {
          for (final eId in entry.value) {
            final entity = _entities[eId];
            if (entity != null) {
              matches.add(LinkedEntityMatch(
                entity: entity,
                matchedText: text,
                charStart: 0,
                charEnd: text.length,
                confidence: sim,
                matchType: MatchType.normalizedFuzzy,
              ));
            }
          }
        }
      }
    }

    // Deduplicate overlapping matches prioritizing highest confidence & length
    matches.sort((a, b) {
      final confComp = b.confidence.compareTo(a.confidence);
      if (confComp != 0) return confComp;
      return (b.charEnd - b.charStart).compareTo(a.charEnd - a.charStart);
    });

    final filtered = <LinkedEntityMatch>[];
    for (final m in matches) {
      final overlaps = filtered.any((existing) =>
          math.max(m.charStart, existing.charStart) < math.min(m.charEnd, existing.charEnd));
      if (!overlaps) {
        filtered.add(m);
      }
    }

    return filtered;
  }

  /// Jaro-Winkler string distance algorithm.
  static double _jaroWinklerSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final matchWindow = (math.max(s1.length, s2.length) / 2).floor() - 1;
    final s1Matches = List<bool>.filled(s1.length, false);
    final s2Matches = List<bool>.filled(s2.length, false);

    int matches = 0;
    for (int i = 0; i < s1.length; i++) {
      final start = math.max(0, i - matchWindow);
      final end = math.min(i + matchWindow + 1, s2.length);

      for (int j = start; j < end; j++) {
        if (!s2Matches[j] && s1[i] == s2[j]) {
          s1Matches[i] = true;
          s2Matches[j] = true;
          matches++;
          break;
        }
      }
    }

    if (matches == 0) return 0.0;

    double transpositions = 0.0;
    int k = 0;
    for (int i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;
      while (!s2Matches[k]) {
        k++;
      }
      if (s1[i] != s2[k]) transpositions++;
      k++;
    }

    final jaro = (matches / s1.length +
            matches / s2.length +
            (matches - transpositions / 2) / matches) /
        3.0;

    // Winkler prefix bonus
    int prefix = 0;
    for (int i = 0; i < math.min(4, math.min(s1.length, s2.length)); i++) {
      if (s1[i] == s2[i]) {
        prefix++;
      } else {
        break;
      }
    }

    return jaro + prefix * 0.1 * (1.0 - jaro);
  }
}
