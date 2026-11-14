import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/indic_languages_registry.dart';

void main() {
  test('Registers Indic Devanagari language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    IndicLanguagesRegistry.registerProfiles(engine);

    final hi = engine.getProfile('hi');
    expect(hi, isNotNull);
    expect(hi!.scriptFamily, equals('Devanagari'));
    expect(hi.typology, equals('SOV'));

    final mr = engine.getProfile('mr');
    expect(mr, isNotNull);
    expect(mr!.genders, contains('n'));
  });
}
