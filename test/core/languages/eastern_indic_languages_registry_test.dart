import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/eastern_indic_languages_registry.dart';

void main() {
  test('Registers Eastern Indic language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    EasternIndicLanguagesRegistry.registerProfiles(engine);

    final bn = engine.getProfile('bn');
    expect(bn, isNotNull);
    expect(bn!.scriptFamily, equals('Bengali'));
    expect(bn.typology, equals('SOV'));

    final orLang = engine.getProfile('or');
    expect(orLang, isNotNull);
    expect(orLang!.casesCount, equals(6));
  });
}
