enum LanguageSupportTier {
  productionReady,
  candidateBeta,
  communityExperimental,
  unsupported,
}

class LanguageReadinessInfo {
  final String languageCode;
  final LanguageSupportTier tier;
  final bool hasOfflineContent;
  final bool hasVoicePack;
  final String fallbackLanguageCode;

  const LanguageReadinessInfo({
    required this.languageCode,
    required this.tier,
    required this.hasOfflineContent,
    this.hasVoicePack = false,
    this.fallbackLanguageCode = 'de',
  });

  bool get isInteractive => tier != LanguageSupportTier.unsupported && hasOfflineContent;
}

/// LanguageReadinessGuard - Master Constitution Section 07 Compliant:
/// Strictly guarantees that selecting a language or pair with incomplete assets
/// displays an informative status rather than throwing a null assertion error.
class LanguageReadinessGuard {
  final Map<String, LanguageReadinessInfo> _registry;

  const LanguageReadinessGuard(this._registry);

  /// Safe query returning guaranteed non-null readiness info with safe fallback
  LanguageReadinessInfo resolveLanguage(String? languageCode) {
    if (languageCode == null || languageCode.trim().isEmpty) {
      return const LanguageReadinessInfo(
        languageCode: 'unknown',
        tier: LanguageSupportTier.unsupported,
        hasOfflineContent: false,
      );
    }

    final code = languageCode.trim().toLowerCase();
    if (_registry.containsKey(code)) {
      return _registry[code]!;
    }

    // Default graceful fallback for unseeded languages
    return LanguageReadinessInfo(
      languageCode: code,
      tier: LanguageSupportTier.unsupported,
      hasOfflineContent: false,
      fallbackLanguageCode: 'de',
    );
  }

  /// Safe pair evaluation: checks both source and target without throwing
  bool canActivatePair(String sourceCode, String targetCode) {
    final src = resolveLanguage(sourceCode);
    final tgt = resolveLanguage(targetCode);
    return src.isInteractive && tgt.isInteractive;
  }
}
