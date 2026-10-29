import 'canonical_language_catalog.dart';

enum LanguageReadinessTier { nominal, assetsReady, ttsVerified, productionReady }

/// Backward-compatible facade. Public registry metadata is NOT a pack proof.
/// Callers that possess accepted verification evidence may pass a lifecycle;
/// without it no language (including German) is claimed production-ready.
class LanguageReadinessMatrix {
  static LanguageReadinessTier getTier(String languageCode,
      {CatalogLifecycle? lifecycle}) {
    if (lifecycle != null &&
        lifecycle.languageCode == languageCode &&
        lifecycle.registered &&
        lifecycle.productionReady) {
      return LanguageReadinessTier.productionReady;
    }
    return LanguageReadinessTier.nominal;
  }

  static bool isProductionReady(String languageCode,
      {CatalogLifecycle? lifecycle}) {
    return getTier(languageCode, lifecycle: lifecycle) ==
        LanguageReadinessTier.productionReady;
  }
}
