/// Diarized speech segment linked to a specific interlocutor.
class DiarizedSegment {
  final String speakerId; // e.g., 'learner', 'tutor_anna', 'waiter_hans'
  final double startSec;
  final double endSec;
  final String transcript;
  final bool isOverlapping;

  const DiarizedSegment({
    required this.speakerId,
    required this.startSec,
    required this.endSec,
    required this.transcript,
    required this.isOverlapping,
  });
}

/// Resolves multiple speaker turns and separates simultaneous overlapping dialogue.
class SpeakerDiarizationResolver {
  /// Segments an interleaved multi-speaker session into chronological speaker turns.
  List<DiarizedSegment> resolveOverlap(List<DiarizedSegment> rawSegments) {
    if (rawSegments.isEmpty) return [];

    final resolved = <DiarizedSegment>[];

    for (int i = 0; i < rawSegments.length; i++) {
      final current = rawSegments[i];
      bool overlap = false;

      // Check overlap against previous or next segments
      if (i > 0 && current.startSec < rawSegments[i - 1].endSec) {
        overlap = true;
      }
      if (i < rawSegments.length - 1 && current.endSec > rawSegments[i + 1].startSec) {
        overlap = true;
      }

      resolved.add(DiarizedSegment(
        speakerId: current.speakerId,
        startSec: current.startSec,
        endSec: current.endSec,
        transcript: current.transcript,
        isOverlapping: overlap,
      ));
    }

    resolved.sort((a, b) => a.startSec.compareTo(b.startSec));
    return resolved;
  }

  /// Calculates total speaking time per speaker.
  Map<String, double> calculateSpeakingDistribution(List<DiarizedSegment> segments) {
    final distribution = <String, double>{};
    for (final seg in segments) {
      final duration = (seg.endSec - seg.startSec).clamp(0.0, 9999.0);
      distribution[seg.speakerId] = (distribution[seg.speakerId] ?? 0.0) + duration;
    }
    return distribution;
  }
}
