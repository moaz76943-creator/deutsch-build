import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_profile.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';

void main() {
  group('DeclarativeLanguageEngine O(N) Tests', () {
    late DeclarativeLanguageEngine engine;

    setUp(() {
      engine = DeclarativeLanguageEngine()..initialize();
    });

    test('Loads default German, Arabic, and English profiles with correct topology', () {
      expect(engine.registeredCount, equals(3));

      final de = engine.getProfile('de');
      expect(de, isNotNull);
      expect(de!.casesCount, equals(4));
      expect(de.isRtl, isFalse);

      final ar = engine.getProfile('ar');
      expect(ar, isNotNull);
      expect(ar!.casesCount, equals(3));
      expect(ar.isRtl, isTrue);
      expect(ar.hasDualNumber, isTrue);
    });

    test('Hot-registers custom new language (Turkish SOV Agglutinative) dynamically', () {
      const tr = LanguageProfile(
        isoCode: 'tr',
        autonym: 'Türkçe',
        englishName: 'Turkish',
        scriptDirection: 'ltr',
        scriptFamily: 'Latin',
        typology: 'SOV',
        morphologyType: 'Agglutinative',
        casesCount: 6,
        caseNames: ['Yalın', 'Belirtme', 'Yönelme', 'Bulunma', 'Ayrılma', 'İlgi'],
        genders: ['none'],
        hasArticles: false,
        hasNounDeclension: true,
        hasVerbConjugation: true,
      );

      engine.registerProfile(tr);
      expect(engine.registeredCount, equals(4));

      final fetched = engine.getProfile('tr');
      expect(fetched, isNotNull);
      expect(fetched!.morphologyType, equals('Agglutinative'));
      expect(fetched.typology, equals('SOV'));
    });
  });
}
