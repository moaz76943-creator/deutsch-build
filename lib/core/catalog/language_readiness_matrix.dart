enum LanguageReadinessTier { nominal, assetsReady, ttsVerified, productionReady }

/// مصفوفة تفصل بين السعة الاسمية والجاهزية الإنتاجية الفعلية لكل لغة
class LanguageReadinessMatrix {
  static final Map<String, LanguageReadinessTier> _tiers = {
    'de': LanguageReadinessTier.productionReady,
    'ar': LanguageReadinessTier.productionReady,
    'en': LanguageReadinessTier.productionReady,
    'fr': LanguageReadinessTier.assetsReady,
    'es': LanguageReadinessTier.assetsReady,
  };

  static LanguageReadinessTier getTier(String languageCode) {
    return _tiers[languageCode] ?? LanguageReadinessTier.nominal;
  }

  static bool isProductionReady(String languageCode) {
    return getTier(languageCode) == LanguageReadinessTier.productionReady;
  }
}
