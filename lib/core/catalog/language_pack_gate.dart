enum PackGateStatus { approved, missingChecksum, schemaMismatch, rejected }

class LanguagePackGateResult {
  final PackGateStatus status;
  final String? reason;

  const LanguagePackGateResult(this.status, [this.reason]);
}

/// بوابة قبول وفحص حزم اللغات قبل تفعيلها للمتعلم
class LanguagePackAcceptanceGate {
  static LanguagePackGateResult evaluatePack({
    required String packCode,
    required int wordCount,
    required String? checksum,
  }) {
    if (packCode.trim().isEmpty) {
      return const LanguagePackGateResult(
        PackGateStatus.rejected,
        'رمز حزمة اللغة غير صالح',
      );
    }
    if (checksum == null || checksum.isEmpty) {
      return const LanguagePackGateResult(
        PackGateStatus.missingChecksum,
        'بصمة التحقق (Checksum) مفقودة',
      );
    }
    if (wordCount <= 0) {
      return const LanguagePackGateResult(
        PackGateStatus.schemaMismatch,
        'الحزمة لا تحتوي على أي مفردات',
      );
    }
    return const LanguagePackGateResult(PackGateStatus.approved);
  }
}
