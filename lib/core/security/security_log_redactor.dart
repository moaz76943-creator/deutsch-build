/// محرك تعتيم وحماية السجلات من تسريب الرموز والمفاتيح والبيانات الحساسة - Phase 7 Security
/// يمنع وصول مفاتيح التشفير، الرموز المميزة (Tokens)، وبيانات الاعتماد إلى الطرفية أو ملفات السجل
class SecurityLogRedactor {
  static final RegExp _bearerPattern = RegExp(
    r'(bearer\s+)[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );

  static final RegExp _sensitiveKeyValuePattern = RegExp(
    r'(token|key|secret|password|pin|credential|hash|authorization)[\s:=]+([^\s,;]+)',
    caseSensitive: false,
  );

  static final RegExp _longHexKeyPattern = RegExp(
    r'\b[a-fA-F0-9]{32,64}\b',
  );

  /// تعتيم أي نص يحتوي على بيانات اعتماد حساسة
  static String redact(String message) {
    if (message.isEmpty) return message;

    var sanitized = message;

    // تعتيم رموز Bearer
    sanitized = sanitized.replaceAllMapped(_bearerPattern, (match) {
      final prefix = match.group(1) ?? 'Bearer ';
      return '${prefix}[REDACTED_TOKEN]';
    });

    // تعتيم أزواج المفتاح والقيمة الحساسة
    sanitized = sanitized.replaceAllMapped(_sensitiveKeyValuePattern, (match) {
      final key = match.group(1) ?? 'credential';
      return '$key=[REDACTED]';
    });

    // تعتيم بصمات الهاش ومفاتيح التشفير الطويلة
    sanitized = sanitized.replaceAllMapped(_longHexKeyPattern, (_) {
      return '[REDACTED_HEX]';
    });

    return sanitized;
  }

  /// التحقق مما إذا كان النص يحتوي على بيانات حساسة غير مشفرة
  static bool containsSensitiveData(String message) {
    return _bearerPattern.hasMatch(message) ||
        _sensitiveKeyValuePattern.hasMatch(message) ||
        _longHexKeyPattern.hasMatch(message);
  }
}
