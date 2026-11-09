import 'package:test/test.dart';
import 'package:deutsch_build/src/core/semantic_search/compressed_radix_lexicon_trie.dart';
import 'package:deutsch_build/src/core/storage/sharded_page_compaction_governor.dart';
import 'package:deutsch_build/src/ui/bridges/vol_113_wave2_ui_bridge.dart';

void main() {
  group('Volume 113 Wave 2 (Tasks 4854-4856) Integration Tests', () {
    test('PERF-004: CompressedRadixLexiconTrie indexes and retrieves prefixes accurately', () {
      final trie = CompressedRadixLexiconTrie();

      trie.insert('schreiben');
      trie.insert('schule');
      trie.insert('schueler');
      trie.insert('arbeiten');

      expect(trie.totalWords, equals(4));

      final resultsSch = trie.findWordsWithPrefix('sch');
      expect(resultsSch.length, equals(3));
      expect(resultsSch.contains('schreiben'), isTrue);
      expect(resultsSch.contains('schule'), isTrue);
      expect(resultsSch.contains('schueler'), isTrue);

      final resultsArb = trie.findWordsWithPrefix('arb');
      expect(resultsArb.length, equals(1));
      expect(resultsArb.first, equals('arbeiten'));

      final resultsNon = trie.findWordsWithPrefix('xyz');
      expect(resultsNon.isEmpty, isTrue);
    });

    test('DATA-005: ShardedPageCompactionGovernor flags high fragmentation and reclaims pages', () async {
      final governor = ShardedPageCompactionGovernor();

      // Healthy shard
      final m1 = governor.registerShardMetrics(shardId: 'shard_de_1', totalPages: 100, deadPages: 10);
      expect(m1.requiresCompaction, isFalse);

      // Fragmented shard
      final m2 = governor.registerShardMetrics(shardId: 'shard_de_2', totalPages: 100, deadPages: 40);
      expect(m2.requiresCompaction, isTrue);

      final reclaimed = await governor.executeScheduledCompaction();
      expect(reclaimed, equals(40));
      expect(governor.totalCompactions, equals(1));
    });

    test('UI Bridge correctly generates Wave 2 diagnostics report', () {
      final bridge = Vol113Wave2UIBridge();
      final report = bridge.getWave2Diagnostics();

      expect(report['volume'], equals(113));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['radix_lexicon_trie']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['page_compaction_governor']['status'], equals('ACTIVE'));
    });
  });
}
