/// Result of an automated ethical and language compliance check.
class SanitizationAuditResult {
  final bool isEthicallyPure;
  final bool isProhibitedLocalesExcluded;
  final List<String> flaggedViolations;
  final int totalScannedWords;

  const SanitizationAuditResult({
    required this.isEthicallyPure,
    required this.isProhibitedLocalesExcluded,
    required this.flaggedViolations,
    required this.totalScannedWords,
  });
}

/// Automated gate scanner ensuring 100% ethical and Sharia purity and zero prohibited language codes.
class LexicalSanitizationAuditEngine {
  static const Set<String> prohibitedLanguageCodes = {'he', 'iw', 'heb'};
  static const Set<String> forbiddenSubstanceKeywords = {
    'bier', 'wein', 'schwein', 'alkohol', 'glücksspiel', 'zinsen', 'casino'
  };

  /// Audits a list of words for moral and ethical purity.
  SanitizationAuditResult auditVocabulary(List<String> words, {String? targetLocale}) {
    final flags = <String>[];
    bool isLangClean = true;

    if (targetLocale != null && prohibitedLanguageCodes.contains(targetLocale.toLowerCase())) {
      isLangClean = false;
      flags.add('Prohibited language code detected: $targetLocale');
    }

    for (final w in words) {
      final clean = w.toLowerCase().trim();
      for (final bad in forbiddenSubstanceKeywords) {
        if (clean.contains(bad)) {
          flags.add('Ethical violation detected: "$w" contains "$bad"');
        }
      }
    }

    return SanitizationAuditResult(
      isEthicallyPure: flags.isEmpty,
      isProhibitedLocalesExcluded: isLangClean,
      flaggedViolations: flags,
      totalScannedWords: words.length,
    );
  }
}
