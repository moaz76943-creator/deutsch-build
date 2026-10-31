/// Canonical entity representation in the sovereign offline knowledge base.
class CanonicalEntity {
  final String entityId;
  final String canonicalName;
  final String category; // location, landmark, historical_figure, organization
  final Map<String, String> localizedAliases; // langCode -> alias
  final String culturalSignificance;

  const CanonicalEntity({
    required this.entityId,
    required this.canonicalName,
    required this.category,
    required this.localizedAliases,
    required this.culturalSignificance,
  });
}

/// Extracted mention within a text passage linked to a knowledge entity.
class EntityMention {
  final String surfaceText;
  final CanonicalEntity linkedEntity;
  final int startIndex;
  final int endIndex;

  const EntityMention({
    required this.surfaceText,
    required this.linkedEntity,
    required this.startIndex,
    required this.endIndex,
  });
}

/// Disambiguates named entities and prevents proper nouns from triggering false grammar/vocab errors.
class MultilingualEntityLinker {
  final List<CanonicalEntity> _entities = [
    const CanonicalEntity(
      entityId: 'ent_brandenburger_tor',
      canonicalName: 'Brandenburger Tor',
      category: 'landmark',
      localizedAliases: {
        'de': 'Brandenburger Tor',
        'en': 'Brandenburg Gate',
        'ar': 'بوابة براندنبورغ',
      },
      culturalSignificance: 'Symbol of German unity and European peace in Berlin.',
    ),
    const CanonicalEntity(
      entityId: 'ent_schwarzwald',
      canonicalName: 'Schwarzwald',
      category: 'location',
      localizedAliases: {
        'de': 'Schwarzwald',
        'en': 'Black Forest',
        'ar': 'الغابة السوداء',
      },
      culturalSignificance: 'Mountainous region in southwestern Germany known for folklore and nature.',
    ),
    const CanonicalEntity(
      entityId: 'ent_goethe',
      canonicalName: 'Johann Wolfgang von Goethe',
      category: 'historical_figure',
      localizedAliases: {
        'de': 'Goethe',
        'en': 'Goethe',
        'ar': 'غوته',
      },
      culturalSignificance: 'Foremost German polymath, poet, and dramatist.',
    ),
  ];

  /// Finds and links all entity mentions within an input text.
  List<EntityMention> linkEntities(String text) {
    if (text.trim().isEmpty) return [];

    final mentions = <EntityMention>[];
    final lowerText = text.toLowerCase();

    for (final entity in _entities) {
      for (final entry in entity.localizedAliases.entries) {
        final alias = entry.value.toLowerCase();
        int searchStart = 0;

        while (true) {
          final idx = lowerText.indexOf(alias, searchStart);
          if (idx == -1) break;

          final matchedSurface = text.substring(idx, idx + alias.length);
          mentions.add(EntityMention(
            surfaceText: matchedSurface,
            linkedEntity: entity,
            startIndex: idx,
            endIndex: idx + alias.length,
          ));
          searchStart = idx + alias.length;
        }
      }
    }

    // Sort by appearance index
    mentions.sort((a, b) => a.startIndex.compareTo(b.startIndex));
    return mentions;
  }
}
