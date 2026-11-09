import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/security/peer_identity_pinning_protocol.dart';
import 'package:deutsch_build/src/core/voice/synthesis/offline_voice_activity_detector.dart';
import 'package:deutsch_build/src/ui/bridges/vol_114_wave3_ui_bridge.dart';

void main() {
  group('Volume 114 Wave 3 (Tasks 4875-4877) Integration Tests', () {
    test('SEC-006: PeerIdentityPinningProtocol pins and enforces identity integrity', () {
      final protocol = PeerIdentityPinningProtocol();
      final validKey = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final rogueKey = Uint8List.fromList([8, 7, 6, 5, 4, 3, 2, 1]);

      protocol.pinPeer('node_charlie', validKey);
      expect(protocol.pinnedPeerCount, equals(1));

      // Correct key must verify cleanly
      expect(protocol.verifyPeer('node_charlie', validKey), isTrue);

      // Rogue key must trigger UntrustedPeerException
      expect(
        () => protocol.verifyPeer('node_charlie', rogueKey),
        throwsA(isA<UntrustedPeerException>()),
      );
    });

    test('P1-15: OfflineVoiceActivityDetector identifies speech vs silence', () {
      final vad = OfflineVoiceActivityDetector(energyThreshold: 200.0);

      // Silence frame (all zeroes)
      final silenceBytes = Uint8List(200);
      final decisionSilence = vad.analyzeFrame(silenceBytes);
      expect(decisionSilence.isSpeech, isFalse);
      expect(decisionSilence.rootMeanSquareEnergy, equals(0.0));

      // Speech frame (high energy wave)
      final speechBytes = Uint8List(200);
      final view = ByteData.sublistView(speechBytes);
      for (int i = 0; i < 100; i++) {
        view.setInt16(i * 2, (i % 2 == 0) ? 2000 : -2000, Endian.little);
      }
      final decisionSpeech = vad.analyzeFrame(speechBytes);
      expect(decisionSpeech.isSpeech, isTrue);
      expect(decisionSpeech.rootMeanSquareEnergy, greaterThan(1000.0));
      expect(decisionSpeech.zeroCrossingRate, greaterThan(10));
    });

    test('UI Bridge correctly generates Wave 3 diagnostics report', () {
      final bridge = Vol114Wave3UIBridge();
      final report = bridge.getWave3Diagnostics();

      expect(report['volume'], equals(114));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['peer_identity_pinning']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['voice_activity_detector']['status'], equals('ACTIVE'));
    });
  });
}
