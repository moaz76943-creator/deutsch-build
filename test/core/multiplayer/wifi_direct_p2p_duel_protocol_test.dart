import 'package:test/test.dart';
import 'package:deutsch_build/src/core/multiplayer/wifi_direct_p2p_duel_protocol.dart';

void main() {
  group('WifiDirectP2pDuelProtocol Tests', () {
    late WifiDirectP2pDuelProtocol hostProtocol;
    late WifiDirectP2pDuelProtocol clientProtocol;

    setUp(() {
      hostProtocol = WifiDirectP2pDuelProtocol(localLearnerId: 'learner_A');
      clientProtocol = WifiDirectP2pDuelProtocol(localLearnerId: 'learner_B');
    });

    test('Serializes and deserializes duel packets faithfully over TCP socket wire', () {
      final packet = hostProtocol.createChallengeOffer(languagePair: 'ar_de');
      final wireString = packet.serialize();

      final deserialized = DuelPacket.deserialize(wireString);
      expect(deserialized.type, equals(DuelPacketType.challengeOffer));
      expect(deserialized.senderId, equals('learner_A'));
      expect(deserialized.payload['pair'], equals('ar_de'));
    });

    test('Synchronizes score updates between host and peer', () {
      final answerPacket = hostProtocol.recordLocalAnswer(isCorrect: true, responseLatencyMs: 850);
      expect(hostProtocol.localScore, equals(10));

      clientProtocol.processIncomingPacket(answerPacket);
      expect(clientProtocol.opponentScore, equals(10));
    });
  });
}
