import 'dart:convert';
import 'dart:typed_data';

class PortableLearnerVaultEngine {
  static const String magic = 'POLYGLOT_VAULT_V3';
  const PortableLearnerVaultEngine();

  Uint8List exportVault(Map<String, dynamic> data, String passphrase) {
    final rawBytes = utf8.encode(jsonEncode(data));
    final keyBytes = utf8.encode(passphrase);
    final enc = Uint8List(rawBytes.length);
    for (int i = 0; i < rawBytes.length; i++) {
      enc[i] = rawBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    final header = utf8.encode('$magic|');
    final out = Uint8List(header.length + enc.length);
    out.setRange(0, header.length, header);
    out.setRange(header.length, out.length, enc);
    return out;
  }

  Map<String, dynamic> importVault(Uint8List bytes, String passphrase) {
    final enc = bytes.sublist(18);
    final keyBytes = utf8.encode(passphrase);
    final dec = Uint8List(enc.length);
    for (int i = 0; i < enc.length; i++) {
      dec[i] = enc[i] ^ keyBytes[i % keyBytes.length];
    }
    return jsonDecode(utf8.decode(dec)) as Map<String, dynamic>;
  }
}
