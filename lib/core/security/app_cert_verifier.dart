import 'package:flutter/foundation.dart';

enum AppSignatureStatus {
  verifiedRelease,
  developmentBypass,
  untrustedSignature,
}

/// التحقق من صحة بصمة توقيع تطبيق أندرويد (Study 30 - APK Signing Certificate Checks)
/// يحمي من استنساخ التطبيق أو تعديل الحزم في بيئة الإنتاج مع الحفاظ على سهولة التطوير المحلي
class AppCertVerifier {
  /// بصمات SHA-256 للشهادات الرسمية المعتمدة (مخصصة للإنتاج)
  static final Set<String> _authorizedReleaseCertSha256 = {
    // بصمة شهادة النشر الرسمية - لا يتم تضمين أي مفاتيح خاصة في المستودع
    '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff',
  };

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
    if (_authorizedReleaseCertSha256.contains(normalized)) {
      return AppSignatureStatus.verifiedRelease;
    }

    return AppSignatureStatus.untrustedSignature;
  }

  /// تسجيل بصمة شهادة جديدة معتمدة (لعمليات التدوير المعتمدة)
  static void registerAuthorizedCertificate(String certSha256) {
    _authorizedReleaseCertSha256.add(
      certSha256.trim().toLowerCase().replaceAll(':', ''),
    );
  }
}
