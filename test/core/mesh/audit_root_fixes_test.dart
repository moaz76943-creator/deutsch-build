import 'package:test/test.dart';
import 'package:deutsch_bilarabi/src/core/mesh/crdt/vector_clock_causality_matrix_tracker.dart';
import 'package:deutsch_bilarabi/src/core/mesh/protocol/chunked_content_hash_merkle_tree_verifier.dart';
import 'package:deutsch_bilarabi/src/core/edge_mesh/crdt_sync/merkle_search_tree_diff_sync_protocol.dart';

void main() {
  group('VectorClock Partial-Order Tests (ARCH-003 Fix)', () {
    test('missing peer counter does NOT dominate local clock', () {
      final local = VectorClock()..tick('A');
      expect(local.dominates({'B': 1}), isFalse);
      expect(local.dominates({'A': 1}), isTrue);
      expect(local.dominates({'A': 1, 'B': 1}), isFalse);
    });

    test('monotonic merge retains maximum counters', () {
      final clockA = VectorClock({'A': 2, 'B': 1});
      final clockB = VectorClock({'B': 3, 'C': 1});
      clockA.merge(clockB);
      expect(clockA.clock, equals({'A': 2, 'B': 3, 'C': 1}));
    });
  });

  group('Merkle Verification Tests (ARCH-002 Fix)', () {
    test('unproved membership strictly fails closed', () {
      final verifier = MerkleChunkVerifier();
      expect(verifier.verifyLeaf('abc', 'def'), isFalse);
    });

    test('real SHA-256 byte verification succeeds on exact match', () {
      final verifier = MerkleChunkVerifier();
      // SHA-256 of "abc" (bytes: [97, 98, 99])
      const expectedSha = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
      expect(verifier.verifyChunkSha256([97, 98, 99], expectedSha), isTrue);
      expect(verifier.verifyChunkSha256([97, 98, 100], expectedSha), isFalse);
    });

    test('deterministic SHA-256 Merkle root computation', () {
      final mst = MerkleSearchTreeSyncProtocol();
      const h1 = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
      const h2 = 'cb8379ac2098aa165029e3938a51da0bcecfc008fd6795f401178647f96c5b34';
      final root = mst.computeRootHash([h1, h2]);
      expect(root, isNot(equals('MST_ROOT_VERIFIED_HASH')));
      expect(root.length, equals(64));
    });
  });
}
