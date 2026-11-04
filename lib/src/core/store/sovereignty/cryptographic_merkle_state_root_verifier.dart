class CryptographicMerkleStateRootVerifier {
  final String expectedRootHash;
  const CryptographicMerkleStateRootVerifier({this.expectedRootHash = 'polyglot_merkle_root_sha256'});
  bool verifyRoot(String calculated) => calculated.toLowerCase() == expectedRootHash.toLowerCase();
}
