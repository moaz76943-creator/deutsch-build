import 'package:deutsch_bilarabi/services/language_pack_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Language registry eligibility', () {
    test('accepts registered base codes and normalized locale tags', () {
      expect(LanguagePackManager.isLocalesSupported('de'), isTrue);
      expect(LanguagePackManager.isLocalesSupported('de-DE'), isTrue);
      expect(LanguagePackManager.isLocalesSupported('ar-SA'), isTrue);
      expect(LanguagePackManager.isLocalesSupported('fr_FR'), isTrue);
      expect(LanguagePackManager.isLanguagesSupported('tr-TR'), isTrue);
    });

    test('rejects unknown, empty and malformed language identifiers', () {
      expect(LanguagePackManager.isLocalesSupported(''), isFalse);
      expect(LanguagePackManager.isLocalesSupported('  '), isFalse);
      expect(LanguagePackManager.isLocalesSupported('zz'), isFalse);
      expect(LanguagePackManager.isLocalesSupported('not-a-code'), isFalse);
      expect(LanguagePackManager.isLocalesSupported('de/../../secret'), isFalse);
      expect(LanguagePackManager.isLanguagesSupported('fake-locale'), isFalse);
    });

    test('registration is separate from installed pack readiness', () {
      expect(LanguagePackManager.isLocalesSupported('fr'), isTrue);
      // The language registry alone must never be used as evidence that
      // a language pack is downloaded, mounted or production-approved.
      expect(LanguagePackManager.supportedLanguages.contains('fr'), isTrue);
      expect(LanguagePackManager.supportedLanguages.contains('zz'), isFalse);
    });
  });
}
