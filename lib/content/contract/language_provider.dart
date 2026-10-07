import 'hundred_languages_registry.dart';
import 'language_pack_loader.dart';

class LanguageProvider {
  String _currentLanguageCode = 'de';

  String get currentLanguageCode => _currentLanguageCode;

  LanguageDefinition get currentLanguage =>
      HundredLanguagesRegistry.getLanguage(_currentLanguageCode);

  Future<void> changeLanguage(String code) async {
    if (LanguagePackLoader.isLanguageSupported(code)) {
      _currentLanguageCode = code;
      await LanguagePackLoader.loadPack(code);
    } else {
      throw Exception('Unsupported language code: $code');
    }
  }

  List<LanguageDefinition> getAvailableLanguages() {
    return HundredLanguagesRegistry.supportedLanguages;
  }
}
