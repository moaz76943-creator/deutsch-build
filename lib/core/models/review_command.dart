import '../architecture/directed_pair_id.dart';

class ReviewCommand {
  final String eventId;
  final DirectedPairId pairId;
  final String cardId;
  final int timestamp;
  final int score;
  final bool usedHint;

  const ReviewCommand({
    required this.eventId,
    required this.pairId,
    required this.cardId,
    required this.timestamp,
    required this.score,
    required this.usedHint,
  });
}
