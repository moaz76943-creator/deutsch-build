import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/slavic_languages_registry.dart';

void main() {
  group('SlavicLanguagesRegistry Tests (RU, UK, PL)', () {
    late DeclarativeLanguageEngine engine;

    setUp(() {
      engine = DeclarativeLanguageEngine()..initialize();
      SlavicLanguagesRegistry.registerProfiles(engine);
    });

    test('Registers Russian, Ukrainian, and Polish successfully', () {
      expect(engine.getProfile('ru'), isNotNull);
      expect(engine.getProfile('uk'), isNotNull);
      expect(engine.getProfile('pl'), isNotNull);

      final ru = engine.getProfile('ru')!;
      expect(ru.scriptFamily, equals('Cyrillic'));
      expect(ru.casesCount, equals(6));
      expect(ru.hasArticles, isFalse);

      final uk = engine.getProfile('uk')!;
      expect(uk.casesCount, equals(7)); // includes Vocative

      final pl = engine.getProfile('pl')!;
      expect(pl.scriptFamily, equals('Latin'));
      expect(pl.casesCount, equals(7));
    });
  });
}
