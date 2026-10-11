import 'package:deutsch_bilarabi/utils/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeQuery', () {
    test('normalizes case, whitespace, and Latin accents', () {
      expect(normalizeQuery('  ÉLÉPHANT   Crème\tBRÛLÉE  '),
          'elephant creme brulee');
      expect(normalizeQuery('façade, piñata, ESPAÑOL'),
          'facade, pinata, espanol');
      expect(normalizeQuery('à è ê ë á í ó ú ü'), 'a e e e a i o u ue');
    });

    test('removes combining accents without corrupting letters', () {
      expect(normalizeQuery('Cafe\u0301  sen\u0303or'), 'cafe senor');
      expect(normalizeQuery('a\u0308'), 'ae');
      expect(normalizeQuery('o\u0308 u\u0308'), 'oe ue');
      expect(fuzzyMatch('Ma\u0308dchen', 'maedchen'), isTrue);
      expect(fuzzyMatch('Mädchen', 'Ma\u0308dchen'), isTrue);
    });

    test('expands German umlauts and sharp s deterministically', () {
      expect(normalizeQuery('Ärger Öffnen ÜBER Straße'),
          'aerger oeffnen ueber strasse');
      expect(normalizeQuery('Fußgänger'), 'fussgaenger');
    });

    test('removes Arabic harakat, tatweel and unifies alef', () {
      expect(normalizeQuery('مُدَرِّسٌ'), 'مدرس');
      expect(normalizeQuery('أَكَلَ إِسْم آدَم ٱسْم'),
          'اكل اسم ادم اسم');
      expect(normalizeQuery('ســلام'), 'سلام');
      expect(normalizeQuery('قُرْآن'), 'قران');
    });

    test('preserves scripts whose characters are not targeted', () {
      expect(normalizeQuery('東京 한국어 किताब Привет'),
          '東京 한국어 किताब привет');
      expect(normalizeQuery(''), '');
      expect(normalizeQuery('  \n\t  '), '');
    });

    test('maps supported Latin ligatures and stroke variants', () {
      expect(normalizeQuery('Œuvre Æther Łódź Øresund'),
          'oeuvre aether lodz oresund');
    });
  });

  group('fuzzyMatch', () {
    test('matches French and Spanish regardless of accents or case', () {
      expect(fuzzyMatch('Crème brûlée', 'CREME BRULEE'), isTrue);
      expect(fuzzyMatch('CREME BRULEE', 'crème'), isTrue);
      expect(fuzzyMatch('España', 'espana'), isTrue);
      expect(fuzzyMatch('Señorita', 'NORI'), isTrue);
    });

    test('matches both German umlaut spellings in either direction', () {
      expect(fuzzyMatch('Mädchen', 'maedchen'), isTrue);
      expect(fuzzyMatch('Mädchen', 'madchen'), isTrue);
      expect(fuzzyMatch('Maedchen', 'mädchen'), isTrue);
      expect(fuzzyMatch('Madchen', 'mädchen'), isTrue);
      expect(fuzzyMatch('Müller', 'muller'), isTrue);
      expect(fuzzyMatch('Müller', 'mueller'), isTrue);
      expect(fuzzyMatch('Über', 'uber'), isTrue);
      expect(fuzzyMatch('über', 'ueber'), isTrue);
      expect(fuzzyMatch('Straße', 'STRASSE'), isTrue);
    });

    test('matches Arabic despite harakat and alef variants', () {
      expect(fuzzyMatch('الْقُرْآنُ الكَرِيمُ', 'القران'), isTrue);
      expect(fuzzyMatch('إِسْلَام', 'اسلام'), isTrue);
      expect(fuzzyMatch('أَحْمَد', 'احمد'), isTrue);
      expect(fuzzyMatch('احمد', 'أَحْمَد'), isTrue);
    });

    test('supports substring matching without arbitrary typo correction', () {
      expect(fuzzyMatch('Fußgänger', 'GÄN'), isTrue);
      expect(fuzzyMatch('Haus', 'Maus'), isFalse);
      expect(fuzzyMatch('Müller', 'Schmidt'), isFalse);
      expect(fuzzyMatch('東京', '京'), isTrue);
      expect(fuzzyMatch('東京', '서울'), isFalse);
    });

    test('does not match an empty or whitespace-only query', () {
      expect(fuzzyMatch('anything', ''), isFalse);
      expect(fuzzyMatch('anything', '   '), isFalse);
      expect(fuzzyMatch('', ''), isFalse);
    });

    test('class static entry points match top-level API', () {
      expect(TextNormalizer.normalizeQuery('École'), normalizeQuery('École'));
      expect(TextNormalizer.fuzzyMatch('Mädchen', 'madchen'),
          fuzzyMatch('Mädchen', 'madchen'));
    });
  });
}
