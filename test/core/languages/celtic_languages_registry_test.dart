import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/celtic_languages_registry.dart';

void main() {
  test('Registers Celtic language profiles with VSO typology', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    CelticLanguagesRegistry.registerProfiles(engine);

    final ga = engine.getProfile('ga');
    expect(ga, isNotNull);
    expect(ga!.typology, equals('VSO'));
    expect(ga.casesCount, equals(4));

    final cy = engine.getProfile('cy');
    expect(cy, isNotNull);
    expect(cy!.typology, equals('VSO'));
  });
}
