import 'package:test/test.dart';
import 'package:deutsch_build/src/core/security/merkle_tree_verifier.dart';

void main() {
  group('MerkleTreeVerifier Tests', () {
    const verifier = MerkleTreeVerifier();

    test('Computes deterministic Merkle root from leaves', () {
      final leaf1 = MerkleTreeVerifier.hashBytes([1, 2, 3]);
      final leaf2 = MerkleTreeVerifier.hashBytes([4, 5, 6]);
      final leaf3 = MerkleTreeVerifier.hashBytes([7, 8, 9]);
      final leaf4 = MerkleTreeVerifier.hashBytes([10, 11, 12]);

      final root = verifier.computeRoot([leaf1, leaf2, leaf3, leaf4]);

      expect(root, isNotEmpty);
      expect(root.length, equals(64)); // SHA-256 hex length
    });

    test('Verifies valid Merkle audit proof and detects single-bit tampering', () {
      final leaf1 = MerkleTreeVerifier.hashBytes([1]);
      final leaf2 = MerkleTreeVerifier.hashBytes([2]);
      final leaf3 = MerkleTreeVerifier.hashBytes([3]);
      final leaf4 = MerkleTreeVerifier.hashBytes([4]);

      final parentRight = MerkleTreeVerifier.combineHashes(leaf3, leaf4);
      final expectedRoot = verifier.computeRoot([leaf1, leaf2, leaf3, leaf4]);

      // Proof for leaf1 (index 0): sibling leaf2, then sibling parentRight
      final proof = MerkleAuditProof(
        leafHash: leaf1,
        leafIndex: 0,
        siblingHashes: [leaf2, parentRight],
      );

      expect(verifier.verifyProof(proof: proof, expectedRoot: expectedRoot), isTrue);

      // Tamper test: Alter leaf hash
      final tamperedProof = MerkleAuditProof(
        leafHash: MerkleTreeVerifier.hashBytes([999]), // Modified data!
        leafIndex: 0,
        siblingHashes: [leaf2, parentRight],
      );

      expect(verifier.verifyProof(proof: tamperedProof, expectedRoot: expectedRoot), isFalse);
    });
  });
}
