import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/uralic_languages_registry.dart';

void main() {
  test('Registers Uralic language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    UralicLanguagesRegistry.registerProfiles(engine);

    final hu = engine.getProfile('hu');
    expect(hu, isNotNull);
    expect(hu!.casesCount, equals(18));
    expect(hu.morphologyType, equals('Agglutinative'));

    final fi = engine.getProfile('fi');
    expect(fi, isNotNull);
    expect(fi!.casesCount, equals(15));
  });
}
