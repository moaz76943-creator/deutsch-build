import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/near_eastern_languages_registry.dart';

void main() {
  group('NearEasternLanguagesRegistry Tests (TR, FA, UR)', () {
    late DeclarativeLanguageEngine engine;

    setUp(() {
      engine = DeclarativeLanguageEngine()..initialize();
      NearEasternLanguagesRegistry.registerProfiles(engine);
    });

    test('Registers Turkish, Persian, and Urdu successfully', () {
      expect(engine.getProfile('tr'), isNotNull);
      expect(engine.getProfile('fa'), isNotNull);
      expect(engine.getProfile('ur'), isNotNull);

      final tr = engine.getProfile('tr')!;
      expect(tr.morphologyType, equals('Agglutinative'));
      expect(tr.typology, equals('SOV'));
      expect(tr.isRtl, isFalse);

      final fa = engine.getProfile('fa')!;
      expect(fa.isRtl, isTrue);
      expect(fa.typology, equals('SOV'));

      final ur = engine.getProfile('ur')!;
      expect(ur.isRtl, isTrue);
      expect(ur.casesCount, equals(3));
    });
  });
}
