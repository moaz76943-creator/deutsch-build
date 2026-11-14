import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_compound_noun_validator.dart';
import 'package:deutsch_build/src/core/security/mesh_peer_ephemeral_handshake.dart';
import 'package:deutsch_build/src/ui/bridges/vol_112_capstone_ui_bridge.dart';

void main() {
  group('Volume 112 Capstone (Tasks 4848-4850) Integration Tests', () {
    test('SEC-005: Mesh Ephemeral Handshake executes authenticated session derivation', () {
      final aliceKey = Uint8List.fromList(List.generate(32, (i) => i + 1));
      final bobKey = Uint8List.fromList(List.generate(32, (i) => i + 50));

      final alice = MeshPeerEphemeralHandshake(
        localNodeId: 'node_alice',
        localPrivateKey: aliceKey,
      );

      final bob = MeshPeerEphemeralHandshake(
        localNodeId: 'node_bob',
        localPrivateKey: bobKey,
      );

      final challenge = alice.initiateHandshake('node_bob');
      expect(challenge['initiator'], equals('node_alice'));
      expect(challenge['target'], equals('node_bob'));

      // Bob accepts with Alice's public/verification key
      final session = bob.acceptHandshake(challenge, aliceKey);
      expect(session.remotePeerId, equals('node_alice'));
      expect(session.sharedKey.isNotEmpty, isTrue);

      // Replaying the same challenge must be rejected
      expect(
        () => bob.acceptHandshake(challenge, aliceKey),
        throwsA(isA<PeerHandshakeException>()),
      );
    });

    test('LING-001: GermanCompoundNounValidator decomposes compounds and extracts gender', () {
      final analysis1 = GermanCompoundNounValidator.analyzeCompound('Schulbuch');
      expect(analysis1.headNoun, equals('buch'));
      expect(analysis1.baseGender, equals(GermanGender.das));
      expect(analysis1.segments, equals(['schul', 'buch']));

      final analysis2 = GermanCompoundNounValidator.analyzeCompound('Sprachlehrer');
      expect(analysis2.headNoun, equals('lehrer'));
      expect(analysis2.baseGender, equals(GermanGender.der));
    });

    test('UI Bridge generates full Volume 112 Capstone Report', () {
      final bridge = Vol112CapstoneUIBridge();
      final report = bridge.getVolume112FullReport();

      expect(report['volume'], equals(112));
      expect(report['milestone_status'], equals('SEALED_AND_VERIFIED'));
      expect(report['volume_verdict'], equals('PRODUCTION_READY'));
    });
  });
}
