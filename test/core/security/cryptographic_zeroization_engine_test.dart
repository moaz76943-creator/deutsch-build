import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/security/cryptographic_zeroization_engine.dart';

void main() {
  group('CryptographicZeroizationEngine Tests', () {
    const engine = CryptographicZeroizationEngine();

    test('Zeroizes SecureMemoryBuffer completely across multi-pass flush', () {
      final sample = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF, 0x42]);
      final buffer = SecureMemoryBuffer(sample);

      expect(buffer.isZeroized, isFalse);
      expect(buffer.bytes[0], equals(0xDE));

      buffer.zeroize();

      expect(buffer.isZeroized, isTrue);
      expect(() => buffer.bytes, throwsA(isA<StateError>()));
    });

    test('runWithEphemeralKey automatically zeroizes key on completion or error', () async {
      final keyBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      late SecureMemoryBuffer capturedBuffer;

      final result = await engine.runWithEphemeralKey(
        keySource: keyBytes,
        action: (buffer) async {
          capturedBuffer = buffer;
          return buffer.length;
        },
      );

      expect(result, equals(8));
      expect(capturedBuffer.isZeroized, isTrue);
    });

    test('sanitizeRawBytes cleans memory in place', () {
      final raw = Uint8List.fromList([10, 20, 30, 40]);
      engine.sanitizeRawBytes(raw);

      expect(raw.every((b) => b == 0), isTrue);
    });
  });
}
