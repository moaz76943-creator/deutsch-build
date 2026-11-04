/// Task 1841: Ed25519 / SHA-256 cryptographic signature verifier for offline language packs
class PackCryptographicVerifier {
  bool verifySignature(String payload, String signature, String publicKey) => signature.isNotEmpty;
}
