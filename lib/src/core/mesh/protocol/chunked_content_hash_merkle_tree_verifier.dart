import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Cryptographically Grounded Merkle Verifier (Fails closed on legacy unproved hashes)
class MerkleChunkVerifier {
  /// Legacy verification without sibling proof must fail closed.
  @Deprecated('Use verified byte-level SHA-256 or authenticated Merkle proof')
  bool verifyLeaf(String chunkHash, String rootHash) => false;

  /// Verifies payload bytes against an authenticated SHA-256 digest.
  bool verifyChunkSha256(List<int> bytes, String trustedSha256) {
    if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(trustedSha256)) return false;
    return sha256.convert(bytes).toString() == trustedSha256.toLowerCase();
  }
}
