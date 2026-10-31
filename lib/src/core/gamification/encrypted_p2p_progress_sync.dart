import 'dart:convert';
import 'dart:typed_data';

class EncryptedP2pProgressSync {
  const EncryptedP2pProgressSync();

  Uint8List encryptSyncPayload(Map<String, dynamic> data, String sharedSecret) {
    final rawBytes = utf8.encode(jsonEncode(data));
    final keyBytes = utf8.encode(sharedSecret);
    final encrypted = Uint8List(rawBytes.length);

    for (int i = 0; i < rawBytes.length; i++) {
      encrypted[i] = rawBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    return encrypted;
  }

  Map<String, dynamic> decryptSyncPayload(Uint8List encrypted, String sharedSecret) {
    final keyBytes = utf8.encode(sharedSecret);
    final decrypted = Uint8List(encrypted.length);

    for (int i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ keyBytes[i % keyBytes.length];
    }
    return jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
  }
}
