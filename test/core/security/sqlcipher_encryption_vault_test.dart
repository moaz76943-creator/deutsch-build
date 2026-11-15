import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/security/sqlcipher_encryption_vault.dart';

void main() {
  group('SqlcipherEncryptionVault Tests', () {
    late SqlcipherEncryptionVault vault;

    setUp(() {
      final key = Uint8List.fromList(utf8.encode('polyglot_sovereign_master_key_32b!'));
      vault = SqlcipherEncryptionVault(masterKey: key);
    });

    test('Encrypts and decrypts learner note accurately', () {
      const originalText = 'ملاحظة خاصة: حفظ أفعال الداتيف الشاذة';
      const context = 'learner_notes_field';

      final payload = vault.encryptField(originalText, context: context);
      expect(payload.ciphertextHex, isNotEmpty);
      expect(payload.ivHex.length, equals(32)); // 16 bytes * 2

      final decrypted = vault.decryptField(payload, context: context);
      expect(decrypted, equals(originalText));
    });

    test('Detects tamper and rejects corrupted payload', () {
      const originalText = 'Top Secret Learner Progress';
      const context = 'progress_field';

      final payload = vault.encryptField(originalText, context: context);
      final corruptedPayload = EncryptedPayload(
        ciphertextHex: payload.ciphertextHex,
        ivHex: payload.ivHex,
        hmacTag: 'corrupted_tag_deadbeef',
      );

      expect(
        () => vault.decryptField(corruptedPayload, context: context),
        throwsA(isA<StateError>()),
      );
    });
  });
}
