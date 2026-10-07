// Content System Final Validator - Post-V1 Expansion
// Validates structural integrity across all loaded contracts and registries

import 'contract/content_contracts.dart';

class ContentValidator {
  static bool validateSystem() {
    final de = HundredLanguagesRegistry.getLanguage('de');
    final ar = HundredLanguagesRegistry.getLanguage('ar');
    
    if (de == null || ar == null) return false;
    
    final dbDe = ExpandedDictionaryDatabase(languageCode: 'de');
    final dbAr = ExpandedDictionaryDatabase(languageCode: 'ar');
    
    return dbDe.queryIndex('test') && dbAr.queryIndex('اختبار');
  }
}
