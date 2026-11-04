import 'dart:convert';
import 'dart:typed_data';

import 'package:deutsch_bilarabi/core/security/aead_backup_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AeadBackupEnvelope envelope;
  final plaintext = Uint8List.fromList(utf8.encode('{"progress":"تعلّم"}'));
  const password = 'backup-test-passphrase';

  setUp(() {
    envelope = AeadBackupCrypto.encryptPayload(
      plaintextBytes: plaintext,
      password: password,
    );
  });

  test('restores learner backup after envelope serialization', () {
    final restored = AeadBackupEnvelope.fromJson(
      jsonDecode(jsonEncode(envelope.toJson())) as Map<String, dynamic>,
    );
    expect(
      AeadBackupCrypto.decryptEnvelope(envelope: restored, password: password),
      plaintext,
    );
  });

  test('rejects the wrong backup password', () {
    expect(
      () => AeadBackupCrypto.decryptEnvelope(
        envelope: envelope,
        password: 'incorrect-password',
      ),
      throwsA(isA<AeadCryptoException>()),
    );
  });

  test('rejects a changed ciphertext before releasing plaintext', () {
    final json = envelope.toJson();
    final first = envelope.ciphertextHex.startsWith('00') ? '01' : '00';
    json['ciphertext'] = first + envelope.ciphertextHex.substring(2);
    expect(
      () => AeadBackupCrypto.decryptEnvelope(
        envelope: AeadBackupEnvelope.fromJson(json),
        password: password,
      ),
      throwsA(isA<AeadCryptoException>()),
    );
  });
}
