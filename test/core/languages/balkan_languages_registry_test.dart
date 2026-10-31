import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/balkan_languages_registry.dart';

void main() {
  test('Registers Balkan language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    BalkanLanguagesRegistry.registerProfiles(engine);

    final el = engine.getProfile('el');
    expect(el, isNotNull);
    expect(el!.scriptFamily, equals('Greek'));
    expect(el.casesCount, equals(4));

    final ro = engine.getProfile('ro');
    expect(ro, isNotNull);
    expect(ro!.hasArticles, isTrue);
  });
}
