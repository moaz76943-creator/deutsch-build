import 'dart:async';

import 'package:sqflite/sqflite.dart';

/// Sense-qualified extension of the legacy ConceptBridgeService.
/// Never falls back to headword-only matches: a missing sense_index or POS
/// column makes a pack ineligible, preventing semantic drift through pivots.
/// The pack manager retains ownership of each already-open database.
class ConceptDisambiguationService {
  ConceptDisambiguationService({
    Map<String, Database> openPackConnections = const {},
  }) {
    for (final entry in openPackConnections.entries) {
      registerOpenPack(entry.key, entry.value);
    }
  }

  static const Duration lookupBudget = Duration(milliseconds: 50);
  final Map<String, Database> _connections = <String, Database>{};

  void registerOpenPack(String languageCode, Database database) {
    _connections[_language(languageCode)] = database;
  }

  void unregisterOpenPack(String languageCode, {Database? connection}) {
    final code = _language(languageCode);
    if (connection == null || identical(_connections[code], connection)) {
      _connections.remove(code);
    }
  }

  /// Looks for exactly one lexical surface matching the shared concept ID,
  /// sense ordinal and part-of-speech in each target pack. Sense ordinals must
  /// be aligned to the same canonical concept inventory across installed packs.
  /// Ambiguous, legacy, closed, slow and unavailable packs are skipped.
  Future<Map<String, String>> findTranslations({
    required String conceptId,
    required int senseIndex,
    required String partOfSpeech,
    required String activeLanguageCode,
  }) async {
    final concept = conceptId.trim();
    final part = partOfSpeech.trim().toLowerCase();
    if (concept.isEmpty || part.isEmpty || senseIndex < 0) {
      return const <String, String>{};
    }
    final active = _language(activeLanguageCode).split('-').first;
    final targets = _connections.entries
        .where((entry) => entry.key.split('-').first != active)
        .toList(growable: false);
    if (targets.isEmpty) return const <String, String>{};

    final matches = <String, String>{};
    var expired = false;
    final watch = Stopwatch()..start();
    final jobs = <Future<void>>[
      for (final target in targets)
        _lookup(target.value, concept, senseIndex, part).then((surface) {
          if (!expired && surface != null) {
            matches[target.key] = surface;
          }
        }),
    ];
    final remaining = lookupBudget - watch.elapsed;
    await Future.any<void>([
      Future.wait(jobs).then<void>((_) {}),
      Future<void>.delayed(
          remaining > Duration.zero ? remaining : Duration.zero),
    ]);
    expired = true;
    return Map<String, String>.unmodifiable(matches);
  }

  static Future<String?> _lookup(
    Database db,
    String conceptId,
    int senseIndex,
    String part,
  ) async {
    try {
      if (!db.isOpen) return null;
      final info = await db.rawQuery('PRAGMA table_info(concepts)');
      final columns = info.map((r) => r['name']).whereType<String>().toSet();
      if (!columns.containsAll(
          {'concept_id', 'surface', 'sense_index', 'part_of_speech'})) {
        return null;
      }

      // LIMIT 2 detects duplicate/ambiguous senses rather than guessing.
      final rows = await db.rawQuery(
        'SELECT surface FROM concepts WHERE concept_id = ? '
        'AND sense_index = ? AND LOWER(TRIM(part_of_speech)) = ? LIMIT 2',
        [conceptId, senseIndex, part],
      );
      if (rows.length != 1) return null;
      final value = rows.single['surface'];
      return value is String && value.trim().isNotEmpty ? value : null;
    } catch (_) {
      // A closed, locked or older schema must not block other packs.
      return null;
    }
  }

  static String _language(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      throw ArgumentError.value(value, 'languageCode', 'Invalid language tag');
    }
    return normalized;
  }
}
