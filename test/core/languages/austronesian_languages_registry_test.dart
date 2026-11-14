import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/austronesian_languages_registry.dart';

void main() {
  test('Registers Austronesian language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    AustronesianLanguagesRegistry.registerProfiles(engine);

    final id = engine.getProfile('id');
    expect(id, isNotNull);
    expect(id!.morphologyType, equals('Agglutinative'));

    final tl = engine.getProfile('tl');
    expect(tl, isNotNull);
    expect(tl!.typology, equals('VSO'));
    expect(tl.casesCount, equals(3));
  });
}
