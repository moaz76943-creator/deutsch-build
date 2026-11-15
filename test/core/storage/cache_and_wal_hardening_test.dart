import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/core/cache/bounded_context_lru.dart';
import 'package:deutsch_bilarabi/src/core/semantic_search/vector_lru_cache_pager.dart';
import 'package:deutsch_bilarabi/src/core/hardening/database/sqlite_wal_checkpoint_auto_governor.dart';
import 'dart:typed_data';

void main() {
  group('MEM-001 BoundedContextLRU Range Tests', () {
    test('rejects slots outside valid range [1, 128]', () {
      expect(() => BoundedContextLRU(0), throwsRangeError);
      expect(() => BoundedContextLRU(-5), throwsRangeError);
      expect(() => BoundedContextLRU(129), throwsRangeError);
    });

    test('accepts valid slot configurations', () {
      final lru = BoundedContextLRU(64);
      expect(lru.capacityBytes, equals(64 * BoundedContextLRU.blockBytes));
    });
  });

  group('MEM-002 VectorLRUCachePager Dirty Eviction Tests', () {
    test('safely flushes dirty pages before eviction', () async {
      final pager = VectorLRUCachePager(maxLoadedPages: 1);
      final page1 = VectorPage(
        pageId: 'page_1',
        vectors: Float32List(128),
        isDirty: true,
        isFlushed: false,
      );
      await pager.putPage(page1);

      final page2 = VectorPage(
        pageId: 'page_2',
        vectors: Float32List(128),
      );
      // Evicting page1 must automatically flush it first without data loss
      await pager.putPage(page2);

      expect(pager.loadedPageCount, equals(1));
      expect(page1.isFlushed, isTrue);
      expect(page1.isDirty, isFalse);
    });
  });

  group('DATA-001/002 SQLite WAL & Atomic Outbox Tests', () {
    test('generates atomic multi-table transaction SQL', () {
      final sql = SqliteWalCheckpointAutoGovernor.generateAtomicTransactionSql(
        snapshotKey: 'card_progress_de',
        snapshotData: '{"level": "C1"}',
        mutationId: 'mut_001',
        mutationPayload: '{"action": "advance"}',
      );
      expect(sql, contains('BEGIN IMMEDIATE TRANSACTION;'));
      expect(sql, contains('INSERT OR REPLACE INTO progress_snapshots'));
      expect(sql, contains('INSERT INTO outbox_mutations'));
      expect(sql, contains('COMMIT;'));
    });
  });
}
