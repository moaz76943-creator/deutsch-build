import 'dart:math';
import 'dart:typed_data';

/// Encapsulates sensitive bytes in memory with guaranteed zeroization on disposal.
class SecureMemoryBuffer {
  final Uint8List _bytes;
  bool _isZeroized = false;

  SecureMemoryBuffer(Uint8List source) : _bytes = Uint8List.fromList(source);

  Uint8List get bytes {
    if (_isZeroized) {
      throw StateError('Cannot access memory buffer: already securely zeroized');
    }
    return _bytes;
  }

  int get length => _bytes.length;
  bool get isZeroized => _isZeroized;

  /// Securely sanitizes the buffer by overwriting bytes with 0x00, 0xFF, and random noise.
  void zeroize() {
    if (_isZeroized) return;

    final random = Random.secure();

    // Pass 1: Overwrite with all 0x00
    _bytes.fillRange(0, _bytes.length, 0x00);

    // Pass 2: Overwrite with all 0xFF
    _bytes.fillRange(0, _bytes.length, 0xFF);

    // Pass 3: Overwrite with cryptographically secure random entropy
    for (int i = 0; i < _bytes.length; i++) {
      _bytes[i] = random.nextInt(256);
    }

    // Final Pass: Final flush to zero
    _bytes.fillRange(0, _bytes.length, 0x00);

    _isZeroized = true;
  }
}

/// Engine providing cryptographic memory zeroization and ephemeral key lifecycle guards.
class CryptographicZeroizationEngine {
  const CryptographicZeroizationEngine();

  /// Executes an operation with a temporary key buffer and ensures immediate zeroization.
  Future<R> runWithEphemeralKey<R>({
    required Uint8List keySource,
    required Future<R> Function(SecureMemoryBuffer secureBuffer) action,
  }) async {
    final buffer = SecureMemoryBuffer(keySource);
    try {
      return await action(buffer);
    } finally {
      buffer.zeroize();
    }
  }

  /// Sanitizes an arbitrary byte array in-place.
  void sanitizeRawBytes(Uint8List target) {
    if (target.isEmpty) return;
    target.fillRange(0, target.length, 0x00);
    target.fillRange(0, target.length, 0xFF);
    target.fillRange(0, target.length, 0x00);
  }
}
