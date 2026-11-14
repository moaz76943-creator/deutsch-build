import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/western_languages_registry.dart';

void main() {
  group('WesternLanguagesRegistry Tests (EN, FR, ES)', () {
    late DeclarativeLanguageEngine engine;

    setUp(() {
      engine = DeclarativeLanguageEngine()..initialize();
      WesternLanguagesRegistry.registerWesternProfiles(engine);
    });

    test('Registers English, French, and Spanish successfully', () {
      expect(engine.getProfile('en'), isNotNull);
      expect(engine.getProfile('fr'), isNotNull);
      expect(engine.getProfile('es'), isNotNull);

      final fr = engine.getProfile('fr')!;
      expect(fr.genders, equals(['m', 'f']));
      expect(fr.scriptFamily, equals('Latin'));

      final es = engine.getProfile('es')!;
      expect(es.autonym, equals('Español'));
      expect(es.typology, equals('SVO'));
    });
  });
}
