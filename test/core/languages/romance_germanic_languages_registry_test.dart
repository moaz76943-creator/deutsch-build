import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/romance_germanic_languages_registry.dart';

void main() {
  group('RomanceGermanicLanguagesRegistry Tests (IT, PT, NL)', () {
    late DeclarativeLanguageEngine engine;

    setUp(() {
      engine = DeclarativeLanguageEngine()..initialize();
      RomanceGermanicLanguagesRegistry.registerProfiles(engine);
    });

    test('Registers Italian, Portuguese, and Dutch successfully', () {
      expect(engine.getProfile('it'), isNotNull);
      expect(engine.getProfile('pt'), isNotNull);
      expect(engine.getProfile('nl'), isNotNull);

      final it = engine.getProfile('it')!;
      expect(it.autonym, equals('Italiano'));

      final pt = engine.getProfile('pt')!;
      expect(pt.englishName, equals('Portuguese'));

      final nl = engine.getProfile('nl')!;
      expect(nl.genders, contains('common'));
    });
  });
}
