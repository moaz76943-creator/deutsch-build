import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/tonal_southeast_asian_languages_registry.dart';

void main() {
  test('Registers Tonal Southeast Asian language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    TonalSoutheastAsianLanguagesRegistry.registerProfiles(engine);

    final th = engine.getProfile('th');
    expect(th, isNotNull);
    expect(th!.morphologyType, equals('Isolating'));
    expect(th.typology, equals('SVO'));

    final myLang = engine.getProfile('my');
    expect(myLang, isNotNull);
    expect(myLang!.typology, equals('SOV'));
  });
}
