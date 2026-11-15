import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/sync/p2p_encrypted_progress_sync.dart';

void main() {
  group('P2pEncryptedProgressSync Tests', () {
    late P2pEncryptedProgressSync syncEngine;

    setUp(() {
      final secret = Uint8List.fromList(utf8.encode('polyglot_32byte_p2p_sync_secret!'));
      syncEngine = P2pEncryptedProgressSync(sharedPairingSecret: secret);
    });

    test('Packs, encrypts, and decrypts progress snapshots accurately', () {
      final items = [
        const SyncProgressItem(itemId: 'word_01', repetitionCount: 5, stability: 12.5, lastReviewedTimestamp: 1000),
        const SyncProgressItem(itemId: 'word_02', repetitionCount: 2, stability: 4.0, lastReviewedTimestamp: 1100),
      ];

      final encrypted = syncEngine.packAndEncryptSnapshot(items);
      expect(encrypted, isNotEmpty);

      final decrypted = syncEngine.decryptAndUnpackSnapshot(encrypted);
      expect(decrypted.length, equals(2));
      expect(decrypted.first.itemId, equals('word_01'));
      expect(decrypted.first.stability, equals(12.5));
    });

    test('Reconciles conflicting progress items using Last-Write-Wins', () {
      final local = [
        const SyncProgressItem(itemId: 'word_01', repetitionCount: 2, stability: 4.0, lastReviewedTimestamp: 500),
      ];
      final incoming = [
        const SyncProgressItem(itemId: 'word_01', repetitionCount: 4, stability: 9.0, lastReviewedTimestamp: 800), // Newer!
      ];

      final reconciled = syncEngine.reconcile(localItems: local, incomingItems: incoming);
      expect(reconciled.first.repetitionCount, equals(4)); // Replaced by newer
      expect(reconciled.first.stability, equals(9.0));
    });
  });
}
