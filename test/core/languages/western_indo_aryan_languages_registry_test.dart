import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/western_indo_aryan_languages_registry.dart';

void main() {
  test('Registers Western Indo-Aryan language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    WesternIndoAryanLanguagesRegistry.registerProfiles(engine);

    final pa = engine.getProfile('pa');
    expect(pa, isNotNull);
    expect(pa!.scriptFamily, equals('Gurmukhi'));

    final sd = engine.getProfile('sd');
    expect(sd, isNotNull);
    expect(sd!.isRtl, isTrue);
  });
}
