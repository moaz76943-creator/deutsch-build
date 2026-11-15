import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/nordic_languages_registry.dart';

void main() {
  test('Registers Nordic language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    NordicLanguagesRegistry.registerProfiles(engine);

    final sv = engine.getProfile('sv');
    expect(sv, isNotNull);
    expect(sv!.genders, contains('common'));

    final isLang = engine.getProfile('is');
    expect(isLang, isNotNull);
    expect(isLang!.casesCount, equals(4));
  });
}
