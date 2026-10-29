import 'package:test/test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/semitic_languages_registry.dart';

void main() {
  test('Registers Semitic Maltese and Syriac profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    SemiticLanguagesRegistry.registerProfiles(engine);

    final mt = engine.getProfile('mt');
    expect(mt, isNotNull);
    expect(mt!.autonym, equals('Malti'));
    expect(mt.hasDualNumber, isTrue);

    final syc = engine.getProfile('syc');
    expect(syc, isNotNull);
    expect(syc!.isRtl, isTrue);
  });
}
