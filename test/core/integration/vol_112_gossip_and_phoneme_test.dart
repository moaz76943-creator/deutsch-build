import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/mesh/protocol/decentralized_gossip_discovery_protocol.dart';
import 'package:deutsch_build/src/core/voice/synthesis/zero_copy_phoneme_alignment_tokenizer.dart';
import 'package:deutsch_build/src/ui/bridges/vol_112_wave5_ui_bridge.dart';

void main() {
  group('Volume 112 Wave 5 (Tasks 4845-4847) Integration Tests', () {
    test('ARCH-008: Decentralized Gossip Discovery records peers and enforces bounded capacity', () {
      final gossip = DecentralizedGossipDiscoveryProtocol(
        localNodeId: 'node_master',
        maxNeighbors: 2,
        peerTimeout: const Duration(milliseconds: 50),
      );

      expect(gossip.recordHeartbeat('peer_1', '192.168.1.10', 8080, 1), isTrue);
      expect(gossip.recordHeartbeat('peer_2', '192.168.1.11', 8080, 1), isTrue);
      expect(gossip.activePeerCount, equals(2));

      // Over capacity attempt
      expect(gossip.recordHeartbeat('peer_3', '192.168.1.12', 8080, 1), isFalse);

      // Heartbeat with lower sequence should be rejected
      expect(gossip.recordHeartbeat('peer_1', '192.168.1.10', 8080, 0), isFalse);
    });

    test('P1-11: ZeroCopyPhonemeAlignmentTokenizer tokenizes German graphemes with accurate durations', () {
      final tokens = ZeroCopyPhonemeAlignmentTokenizer.tokenizeGerman('schule');

      expect(tokens.isNotEmpty, isTrue);
      expect(tokens.first.phoneme, equals('sch'));
      expect(tokens.first.durationMs, equals(130));

      final totalDuration = ZeroCopyPhonemeAlignmentTokenizer.calculateTotalDurationMs(tokens);
      expect(totalDuration, greaterThan(300));
    });

    test('UI Bridge correctly generates Wave 5 diagnostics report', () {
      final bridge = Vol112Wave5UIBridge();
      final report = bridge.getWave5Diagnostics();

      expect(report['volume'], equals(112));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['mesh_gossip_protocol']['status'], equals('HEALTHY'));
      expect(report['subsystems']['phoneme_tokenizer']['status'], equals('OPERATIONAL'));
      expect(bridge.estimateSpeechDuration('hallo'), greaterThan(0));
    });
  });
}
