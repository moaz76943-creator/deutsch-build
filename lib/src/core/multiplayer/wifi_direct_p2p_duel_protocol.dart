import 'dart:convert';

/// Packet action type exchanged during an offline Wi-Fi Direct duel.
enum DuelPacketType {
  challengeOffer,
  challengeAccept,
  roundQuestion,
  answerSubmission,
  scoreSync,
  duelFinished,
}

/// Structured peer-to-peer duel packet.
class DuelPacket {
  final DuelPacketType type;
  final String senderId;
  final int roundIndex;
  final Map<String, dynamic> payload;
  final int timestampMs;

  const DuelPacket({
    required this.type,
    required this.senderId,
    required this.roundIndex,
    required this.payload,
    required this.timestampMs,
  });

  String serialize() => jsonEncode({
        't': type.name,
        's': senderId,
        'r': roundIndex,
        'p': payload,
        'ts': timestampMs,
      });

  factory DuelPacket.deserialize(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return DuelPacket(
      type: DuelPacketType.values.firstWhere((e) => e.name == map['t']),
      senderId: map['s'] as String,
      roundIndex: map['r'] as int,
      payload: Map<String, dynamic>.from(map['p'] as Map),
      timestampMs: map['ts'] as int,
    );
  }
}

/// Coordinates Wi-Fi Direct socket messaging for real-time vocabulary duels.
class WifiDirectP2pDuelProtocol {
  final String localLearnerId;

  int _localScore = 0;
  int _opponentScore = 0;
  int _currentRound = 0;

  WifiDirectP2pDuelProtocol({required this.localLearnerId});

  int get localScore => _localScore;
  int get opponentScore => _opponentScore;
  int get currentRound => _currentRound;

  /// Creates challenge offer packet for local peer.
  DuelPacket createChallengeOffer({required String languagePair}) {
    return DuelPacket(
      type: DuelPacketType.challengeOffer,
      senderId: localLearnerId,
      roundIndex: 0,
      payload: {'pair': languagePair, 'totalRounds': 5},
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Processes incoming packet from opponent peer.
  void processIncomingPacket(DuelPacket packet) {
    switch (packet.type) {
      case DuelPacketType.challengeOffer:
      case DuelPacketType.challengeAccept:
        _currentRound = 1;
        break;
      case DuelPacketType.scoreSync:
        _opponentScore = packet.payload['score'] as int? ?? _opponentScore;
        break;
      case DuelPacketType.answerSubmission:
        final isCorrect = packet.payload['correct'] as bool? ?? false;
        if (isCorrect) {
          _opponentScore += 10;
        }
        break;
      default:
        break;
    }
  }

  /// Records local learner answer and returns sync packet.
  DuelPacket recordLocalAnswer({required bool isCorrect, required int responseLatencyMs}) {
    if (isCorrect) {
      _localScore += 10;
    }
    _currentRound++;

    return DuelPacket(
      type: DuelPacketType.answerSubmission,
      senderId: localLearnerId,
      roundIndex: _currentRound,
      payload: {
        'correct': isCorrect,
        'latencyMs': responseLatencyMs,
        'currentScore': _localScore,
      },
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
