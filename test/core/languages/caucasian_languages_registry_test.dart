import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/caucasian_languages_registry.dart';

void main() {
  test('Registers Caucasian language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    CaucasianLanguagesRegistry.registerProfiles(engine);

    final ka = engine.getProfile('ka');
    expect(ka, isNotNull);
    expect(ka!.casesCount, equals(7));
    expect(ka.caseNames, contains('Ergative'));

    final hy = engine.getProfile('hy');
    expect(hy, isNotNull);
    expect(hy!.scriptFamily, equals('Armenian'));
  });
}
