import 'dart:convert';

/// Opaque credential required only by the authenticated session layer.
///
/// The model intentionally exposes only the opaque value. Concrete credential
/// semantics belong to the backend contract, not to unrelated application state.
final class SecureSessionCredentials {
  static const int maxValueBytes = 16 * 1024;

  factory SecureSessionCredentials(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be empty');
    }
    final valueBytes = utf8.encode(value);
    if (valueBytes.length > maxValueBytes) {
      throw ArgumentError.value(value, 'value', 'exceeds the maximum size');
    }
    return SecureSessionCredentials._(value);
  }

  const SecureSessionCredentials._(this.value);

  final String value;
}
