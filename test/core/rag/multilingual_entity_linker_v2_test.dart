import 'package:test/test.dart';
import 'package:deutsch_build/src/core/rag/multilingual_entity_linker_v2.dart';

void main() {
  group('MultilingualEntityLinkerV2 Suite', () {
    final linker = MultilingualEntityLinkerV2();

    setUpAll(() {
      linker.registerEntity(const SovereignEntity(
        entityId: 'ent_cordoba',
        canonicalName: 'Córdoba',
        category: EntityCategory.location,
        multilingualAliases: {
          'ar': ['قرطبة', 'مدينة قرطبة'],
          'es': ['Córdoba', 'Cordoba'],
          'tr': ['Kurtuba'],
          'en': ['Cordova', 'Cordoba'],
        },
      ));

      linker.registerEntity(const SovereignEntity(
        entityId: 'ent_al_khwarizmi',
        canonicalName: 'Muhammad ibn Musa al-Khwarizmi',
        category: EntityCategory.scholar,
        multilingualAliases: {
          'ar': ['الخوارزمي', 'محمد بن موسى الخوارزمي'],
          'en': ['Al-Khwarizmi', 'Algoritmi'],
          'tr': ['Harezmi'],
          'id': ['Al-Khawarizmi'],
        },
      ));
    });

    test('Links Arabic surface forms with tashkeel and variant spelling', () {
      const text = 'زار الباحث مَدِينَةَ قُرْطُبَةَ في رحلته التاريخية';
      final matches = linker.linkEntities(text: text, languageCode: 'ar');

      expect(matches, isNotEmpty);
      expect(matches.first.entity.entityId, equals('ent_cordoba'));
      expect(matches.first.confidence, equals(1.0));
    });

    test('Links Turkish and Indonesian aliases to identical canonical entity', () {
      final trMatches = linker.linkEntities(text: 'Kurtuba şehri çok güzel', languageCode: 'tr');
      expect(trMatches.first.entity.entityId, equals('ent_cordoba'));

      final idMatches = linker.linkEntities(text: 'Karya besar Al-Khawarizmi dalam aljabar', languageCode: 'id');
      expect(idMatches.first.entity.entityId, equals('ent_al_khwarizmi'));
    });
  });
}
