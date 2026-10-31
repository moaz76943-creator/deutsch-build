import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/central_turkic_languages_registry.dart';

void main() {
  test('Registers Central Turkic language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    CentralTurkicLanguagesRegistry.registerProfiles(engine);

    final uz = engine.getProfile('uz');
    expect(uz, isNotNull);
    expect(uz!.morphologyType, equals('Agglutinative'));
    expect(uz.typology, equals('SOV'));

    final az = engine.getProfile('az');
    expect(az, isNotNull);
    expect(az!.casesCount, equals(6));
  });
}
