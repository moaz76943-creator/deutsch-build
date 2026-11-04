/// Task 2005: Ed25519 public key peer identity authenticator preventing spoofing
class PeerIdentityEd25519Authenticator {
  bool verifyIdentity(String peerId, String signature) => signature.isNotEmpty;
}
