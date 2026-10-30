/// Redacted PII match report.
class ScrubResult {
  final String sanitizedText;
  final int redactedItemsCount;
  final List<String> detectedPiiTypes;

  const ScrubResult({
    required this.sanitizedText,
    required this.redactedItemsCount,
    required this.detectedPiiTypes,
  });
}

/// Zero-cloud on-device PII scrubber ensuring learner privacy before local embedding or caching.
class SemanticPiiScrubber {
  static final RegExp _emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  static final RegExp _phoneRegex = RegExp(r'(\+?[0-9]{1,3}[-.\s]?)?(\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}');
  static final RegExp _ibanRegex = RegExp(r'[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}');

  /// Scrubs all identified sensitive PII patterns from learner journal or speech text.
  ScrubResult scrub(String input) {
    if (input.trim().isEmpty) {
      return const ScrubResult(sanitizedText: '', redactedItemsCount: 0, detectedPiiTypes: []);
    }

    String sanitized = input;
    int count = 0;
    final types = <String>{};

    // Scrub Emails
    if (_emailRegex.hasMatch(sanitized)) {
      count += _emailRegex.allMatches(sanitized).length;
      sanitized = sanitized.replaceAll(_emailRegex, '[EMAIL_REDACTED]');
      types.add('email');
    }

    // Scrub IBAN / Banking
    if (_ibanRegex.hasMatch(sanitized)) {
      count += _ibanRegex.allMatches(sanitized).length;
      sanitized = sanitized.replaceAll(_ibanRegex, '[IBAN_REDACTED]');
      types.add('financial_iban');
    }

    // Scrub Phone numbers
    if (_phoneRegex.hasMatch(sanitized)) {
      count += _phoneRegex.allMatches(sanitized).length;
      sanitized = sanitized.replaceAll(_phoneRegex, '[PHONE_REDACTED]');
      types.add('phone_number');
    }

    return ScrubResult(
      sanitizedText: sanitized,
      redactedItemsCount: count,
      detectedPiiTypes: types.toList()..sort(),
    );
  }
}
