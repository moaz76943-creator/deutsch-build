import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Cryptographic audit proof verifying a specific leaf belongs to the Merkle root.
class MerkleAuditProof {
  final String leafHash;
  final int leafIndex;
  final List<String> siblingHashes;

  const MerkleAuditProof({
    required this.leafHash,
    required this.leafIndex,
    required this.siblingHashes,
  });
}

/// Computes binary Merkle trees and verifies integrity proofs in O(log N).
class MerkleTreeVerifier {
  const MerkleTreeVerifier();

  /// Computes SHA-256 hash of raw byte chunk.
  static String hashBytes(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Combines two hashes and produces parent node hash.
  static String combineHashes(String left, String right) {
    final combined = utf8.encode('$left$right');
    return sha256.convert(combined).toString();
  }

  /// Builds a complete Merkle root from a list of raw block hashes.
  String computeRoot(List<String> leafHashes) {
    if (leafHashes.isEmpty) return '';
    if (leafHashes.length == 1) return leafHashes.first;

    List<String> currentLevel = List.from(leafHashes);

    while (currentLevel.length > 1) {
      final List<String> nextLevel = [];
      for (int i = 0; i < currentLevel.length; i += 2) {
        final left = currentLevel[i];
        final right = (i + 1 < currentLevel.length) ? currentLevel[i + 1] : left; // Duplicate odd leaf
        nextLevel.add(combineHashes(left, right));
      }
      currentLevel = nextLevel;
    }

    return currentLevel.first;
  }

  /// Verifies whether an individual leaf belongs to the expected Merkle root using its proof.
  bool verifyProof({
    required MerkleAuditProof proof,
    required String expectedRoot,
  }) {
    String currentHash = proof.leafHash;
    int index = proof.leafIndex;

    for (final sibling in proof.siblingHashes) {
      if (index % 2 == 0) {
        currentHash = combineHashes(currentHash, sibling);
      } else {
        currentHash = combineHashes(sibling, currentHash);
      }
      index ~/= 2;
    }

    return currentHash.toLowerCase() == expectedRoot.toLowerCase();
  }
}
