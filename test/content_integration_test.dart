import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/content/contract/hundred_languages_registry.dart';

void main() {
  test('Language integration test', () {
    final lang = HundredLanguagesRegistry.getLanguage('de');
    expect(lang.code, 'de');
  });
}
