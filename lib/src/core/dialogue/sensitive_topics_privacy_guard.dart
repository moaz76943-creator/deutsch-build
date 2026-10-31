enum SensitiveCategory {
  personallyIdentifiableInfo,
  profanityOrHarassment,
  offTopicDispute,
}

class PrivacyGuardReport {
  final bool isClean;
  final SensitiveCategory? flaggedCategory;
  final String sanitizedText;
  final String? educationalPivotResponse;

  const PrivacyGuardReport({
    required this.isClean,
    required this.sanitizedText,
    this.flaggedCategory,
    this.educationalPivotResponse,
  });

  Map<String, dynamic> toJson() => {
    'isClean': isClean,
    'flaggedCategory': flaggedCategory?.name,
    'sanitizedText': sanitizedText,
    'hasPivot': educationalPivotResponse != null,
  };
}

class SensitiveTopicsPrivacyGuard {
  static final RegExp _emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  static final RegExp _ibanRegex = RegExp(r'[A-Z]{2}\d{2}[A-Z0-9]{12,30}');
  static final RegExp _phoneRegex = RegExp(r'(\+?\d{1,3}[-.\s]?)?(\(?\d{2,4}\)?[-.\s]?)?\d{3,4}[-.\s]?\d{3,4}');
  static final RegExp _creditCardRegex = RegExp(r'\b(?:\d{4}[-\s]?){3}\d{4}\b');

  static const Set<String> _profanityList = {
    'schlampe', 'arschloch', 'hurensohn', 'idiot', 'scheiße', 'fuck', 'bastard'
  };

  const SensitiveTopicsPrivacyGuard();

  /// Inspects learner text, redacts sensitive PII, and flags inappropriate content.
  PrivacyGuardReport inspectAndSanitize(String input) {
    String sanitized = input;
    bool hasPii = false;

    // Redact Credit Cards
    if (_creditCardRegex.hasMatch(sanitized)) {
      sanitized = sanitized.replaceAll(_creditCardRegex, '[KREDITKARTE REDAKTIERT]');
      hasPii = true;
    }

    // Redact IBAN
    if (_ibanRegex.hasMatch(sanitized)) {
      sanitized = sanitized.replaceAll(_ibanRegex, '[IBAN REDAKTIERT]');
      hasPii = true;
    }

    // Redact Email
    if (_emailRegex.hasMatch(sanitized)) {
      sanitized = sanitized.replaceAll(_emailRegex, '[E-MAIL REDAKTIERT]');
      hasPii = true;
    }

    // Redact Phone numbers (length > 7)
    if (_phoneRegex.hasMatch(sanitized) && sanitized.replaceAll(RegExp(r'\D'), '').length >= 8) {
      sanitized = sanitized.replaceAll(_phoneRegex, '[TELEFONNUMMER REDAKTIERT]');
      hasPii = true;
    }

    // Check Profanity
    final lower = sanitized.toLowerCase();
    for (final badWord in _profanityList) {
      if (lower.contains(badWord)) {
        return PrivacyGuardReport(
          isClean: false,
          flaggedCategory: SensitiveCategory.profanityOrHarassment,
          sanitizedText: sanitized,
          educationalPivotResponse: 'Als Sprachassistent konzentriere ich mich auf respektvolles Sprachtraining. Lass uns bitte in einem freundlichen Ton weitersprechen!',
        );
      }
    }

    if (hasPii) {
      return PrivacyGuardReport(
        isClean: true,
        flaggedCategory: SensitiveCategory.personallyIdentifiableInfo,
        sanitizedText: sanitized,
        educationalPivotResponse: 'Hinweis: Deine sensiblen persönlichen Daten wurden zu deinem Schutz lokal maskiert.',
      );
    }

    return PrivacyGuardReport(
      isClean: true,
      sanitizedText: sanitized,
    );
  }
}
