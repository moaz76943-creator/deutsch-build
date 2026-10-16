import 'package:flutter/foundation.dart';

enum AppSignatureStatus {
  verifiedRelease,
  developmentBypass,
  untrustedSignature,
}

/// التحقق من صحة بصمة توقيع تطبيق أندرويد (Study 30 - APK Signing Certificate Checks)
/// يحمي من استنساخ التطبيق أو تعديل الحزم في بيئة الإنتاج مع الحفاظ على سهولة التطوير المحلي
class AppCertVerifier {
  /// البصمات المعروفة للشهادات الوهمية أو عناصر الاختبار النائبة.
  /// يحظر تماماً قبولها كشهادات رسمية في الإنتاج.
  static const Set<String> knownPlaceholderFingerprints = {
    '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff',
    '0000000000000000000000000000000000000000000000000000000000000000',
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
  };

  /// بصمات SHA-256 للشهادات الرسمية المعتمدة (مخصصة للإنتاج)
  static final Set<String> _authorizedReleaseCertSha256 = {};

  /// فحص بصمة الشهادة الفعلية
  static AppSignatureStatus verifySignature({
    required String currentApkCertSha256,
    bool isReleaseMode = kReleaseMode,
  }) {
    // في بيئة التطوير (Debug/Profile)، يتم التجاوز بأمان لتفادي تعطيل المطورين
    if (!isReleaseMode) {
      return AppSignatureStatus.developmentBypass;
    }

    final normalized = currentApkCertSha256.trim().toLowerCase().replaceAll(':', '');
    if (knownPlaceholderFingerprints.contains(normalized)) {
      return AppSignatureStatus.untrustedSignature;
    }

    if (_authorizedReleaseCertSha256.contains(normalized)) {
      return AppSignatureStatus.verifiedRelease;
    }

    return AppSignatureStatus.untrustedSignature;
  }

  /// تسجيل بصمة شهادة جديدة معتمدة (لعمليات التدوير المعتمدة)
  static void registerAuthorizedCertificate(String certSha256) {
    final normalized = certSha256.trim().toLowerCase().replaceAll(':', '');
    if (knownPlaceholderFingerprints.contains(normalized)) {
      throw ArgumentError(
        'Security Error: Cannot register a placeholder or dummy certificate fingerprint',
      );
    }
    _authorizedReleaseCertSha256.add(normalized);
  }

  /// مسح الشهادات المسجلة لإعادة التهيئة في الاختبارات
  @visibleForTesting
  static void clearAuthorizedCertificatesForTesting() {
    _authorizedReleaseCertSha256.clear();
  }
}
