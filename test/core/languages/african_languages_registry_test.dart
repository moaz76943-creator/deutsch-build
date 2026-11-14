import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/african_languages_registry.dart';

void main() {
  test('Registers African language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    AfricanLanguagesRegistry.registerProfiles(engine);

    final sw = engine.getProfile('sw');
    expect(sw, isNotNull);
    expect(sw!.morphologyType, equals('Agglutinative'));

    final am = engine.getProfile('am');
    expect(am, isNotNull);
    expect(am!.typology, equals('SOV'));
    expect(am.scriptFamily, contains("Ge'ez"));
  });
}
