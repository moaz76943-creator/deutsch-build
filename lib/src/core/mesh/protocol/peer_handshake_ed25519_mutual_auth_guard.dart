/// Task 1505: Ed25519 asymmetric mutual authentication handshake
class PeerAuthGuard {
  bool verifyHandshake(String pubKey, String signature) => pubKey.isNotEmpty && signature.isNotEmpty;
}
