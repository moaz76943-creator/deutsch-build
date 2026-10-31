import 'dart:typed_data';

/// آلية تصفير الذاكرة الحساسة ومحو المفاتيح من RAM فور انتهاء العمليات - Study 54
/// تمنع بقاء المفاتيح السرية وكلمات المرور في الذاكرة حتى يجمعها Garbage Collector
class SecretMemoryZeroizer {
  /// تصفير مصفوفة بايتات حساسة (Uint8List) بالكتابة الفورية للأصفار
  static void zeroize(Uint8List? buffer) {
    if (buffer == null || buffer.isEmpty) return;
    buffer.fillRange(0, buffer.length, 0);
  }

  /// تصفير قائمة بايتات عامة
  static void zeroizeList(List<int>? buffer) {
    if (buffer == null || buffer.isEmpty) return;
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] = 0;
    }
  }

  /// تنفيذ عملية تشفير/فك تشفير مع ضمان تصفير السر في كتلة finally
  static T withProtectedSecret<T>({
    required Uint8List secretBytes,
    required T Function(Uint8List) action,
  }) {
    try {
      return action(secretBytes);
    } finally {
      zeroize(secretBytes);
    }
  }

  /// تنفيذ عملية غير متزامنة مع ضمان التصفير
  static Future<T> withProtectedSecretAsync<T>({
    required Uint8List secretBytes,
    required Future<T> Function(Uint8List) action,
  }) async {
    try {
      return await action(secretBytes);
    } finally {
      zeroize(secretBytes);
    }
  }
}
