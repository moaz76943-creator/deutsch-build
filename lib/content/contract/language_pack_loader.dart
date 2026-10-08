import 'hundred_languages_registry.dart';
import 'pack_compiler.dart';

class LanguagePackLoader {
  static Future<Map<String, dynamic>> loadPack(String languageCode) async {
    // محاكاة جلب الحزمة المعمارية للغة المطلوبة محلياً أو من الذاكرة المؤقتة
    final language = HundredLanguagesRegistry.getLanguage(languageCode);
    
    if (language.code.isEmpty) {
      throw Exception('Language pack not found for code: $languageCode');
    }

    return PackCompiler.compileLanguagePack(languageCode);
  }

  static bool isLanguageSupported(String languageCode) {
    return HundredLanguagesRegistry.supportedLanguages
        .any((lang) => lang.code == languageCode);
  }
}
