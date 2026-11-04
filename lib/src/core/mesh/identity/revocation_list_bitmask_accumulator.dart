/// Task 1545: Cryptographic revocation list accumulator checking revoked keys
class KeyRevocationAccumulator {
  final Set<String> _revokedDids = {};
  void revoke(String did) => _revokedDids.add(did);
  bool isRevoked(String did) => _revokedDids.contains(did);
}
