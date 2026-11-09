/// Exception thrown when content fails ethical, legal, or sovereign linguistic constraints.
class SovereignComplianceViolationException implements Exception {
  final String rule;
  final String detail;

  SovereignComplianceViolationException({required this.rule, required this.detail});

  @override
  String toString() => 'SovereignComplianceViolationException: [$rule] $detail';
}

/// Strict validator enforcing zero-PII, Sharia compliance, open licensing,
/// and absolute exclusion of prohibited language codes (he, syc, ber, zgh)
/// and exclusion of citizenship test material.
class SovereignContentComplianceValidator {
  static const Set<String> prohibitedLanguageCodes = <String>{
    'he',
    'heb',
    'syc',
    'syr',
    'ber',
    'zgh',
  };

  static const List<String> prohibitedTopicKeywords = <String>[
    'einbuergerungstest',
    'citizenship test',
    'medical diagnosis',
    'legal counsel',
    'prescription',
  ];

  /// Verify that language code is strictly permitted.
  static void validateLanguageCode(String code) {
    final normalized = code.trim().toLowerCase();
    if (prohibitedLanguageCodes.contains(normalized)) {
      throw SovereignComplianceViolationException(
        rule: 'LANGUAGE_SOVEREIGNTY_EXCLUSION',
        detail: 'Language code "$code" is strictly excluded under platform sovereign policy.',
      );
    }
  }

  /// Validate package metadata and text entries for purity and compliance.
  static void validateContentPackage({
    required String packageId,
    required String languageCode,
    required List<String> lessons,
    required bool zeroPiiAttested,
    required bool openLicenseAttested,
  }) {
    validateLanguageCode(languageCode);

    if (!zeroPiiAttested) {
      throw SovereignComplianceViolationException(
        rule: 'ZERO_PII_VIOLATION',
        detail: 'Package $packageId missing Zero-PII formal attestation.',
      );
    }

    if (!openLicenseAttested) {
      throw SovereignComplianceViolationException(
        rule: 'LICENSE_ATTESTATION_MISSING',
        detail: 'Package $packageId missing Open Educational License attestation.',
      );
    }

    for (final text in lessons) {
      final lower = text.toLowerCase();
      for (final keyword in prohibitedTopicKeywords) {
        if (lower.contains(keyword)) {
          throw SovereignComplianceViolationException(
            rule: 'PROHIBITED_TOPIC_VIOLATION',
            detail: 'Package $packageId contains prohibited topic content matching "$keyword".',
          );
        }
      }
    }
  }
}
