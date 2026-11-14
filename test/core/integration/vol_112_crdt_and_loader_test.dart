import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/dynamic_sovereign_pack_loader.dart';
import 'package:deutsch_build/src/core/content/sovereign_content_compliance_validator.dart';
import 'package:deutsch_build/src/core/mesh/crdt/crdt_delta_pruning_collector.dart';
import 'package:deutsch_build/src/ui/bridges/vol_112_wave4_ui_bridge.dart';

void main() {
  group('Volume 112 Wave 4 (Tasks 4842-4844) Integration Tests', () {
    test('ARCH-006: CRDT Delta Pruning Collector prunes tombstones across stable cuts', () {
      final collector = CrdtDeltaPruningCollector(tombstoneMaxAge: const Duration(days: 7));

      collector.registerTombstone('record_alpha', 10);
      collector.registerTombstone('record_beta', 25);
      expect(collector.activeTombstoneCount, equals(2));

      // Peer has only acknowledged up to timestamp 15
      collector.updatePeerStableTimestamp('peer_node_1', 15);
      collector.updatePeerStableTimestamp('peer_node_2', 20);

      // Should prune record_alpha (10 <= 15) but preserve record_beta (25 > 15)
      final prunedCount = collector.collectGarbage();
      expect(prunedCount, equals(1));
      expect(collector.activeTombstoneCount, equals(1));
    });

    test('ARCH-007: Dynamic Sovereign Pack Loader loads valid manifests and rejects excluded codes', () {
      final loader = DynamicSovereignPackLoader();

      final manifest = loader.loadPackManifest(
        packId: 'de_level_a1',
        languageCode: 'de',
        lessonCount: 45,
        manifestJsonString: '{"title":"German A1"}',
      );

      expect(manifest.packId, equals('de_level_a1'));
      expect(manifest.contentSha256.isNotEmpty, isTrue);
      expect(loader.loadedPackCount, equals(1));

      // Attempt to load prohibited language must throw
      expect(
        () => loader.loadPackManifest(
          packId: 'prohibited_pack',
          languageCode: 'he',
          lessonCount: 10,
          manifestJsonString: '{}',
        ),
        throwsA(isA<SovereignComplianceViolationException>()),
      );
    });

    test('UI Bridge correctly generates Wave 4 diagnostics report', () {
      final bridge = Vol112Wave4UIBridge();
      final report = bridge.getWave4Diagnostics();

      expect(report['volume'], equals(112));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['crdt_tombstone_collector']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['dynamic_sovereign_pack_loader']['status'], equals('ONLINE'));
    });
  });
}
