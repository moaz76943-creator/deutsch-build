import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/speaker_diarization_resolver.dart';

void main() {
  group('SpeakerDiarizationResolver Unit Tests (N069)', () {
    final resolver = SpeakerDiarizationResolver();

    test('Correctly flags overlapping speech intervals between learner and tutor', () {
      final segments = [
        const DiarizedSegment(speakerId: 'tutor', startSec: 1.0, endSec: 4.0, transcript: 'Guten Tag!', isOverlapping: false),
        const DiarizedSegment(speakerId: 'learner', startSec: 3.5, endSec: 5.5, transcript: 'Hallo!', isOverlapping: false), // Overlap at 3.5-4.0
      ];

      final resolved = resolver.resolveOverlap(segments);
      expect(resolved.length, equals(2));
      expect(resolved[0].isOverlapping, isTrue);
      expect(resolved[1].isOverlapping, isTrue);
    });

    test('Calculates accurate speaker time distribution', () {
      final segments = [
        const DiarizedSegment(speakerId: 'tutor', startSec: 0.0, endSec: 10.0, transcript: 'Frage', isOverlapping: false),
        const DiarizedSegment(speakerId: 'learner', startSec: 10.0, endSec: 15.0, transcript: 'Antwort', isOverlapping: false),
      ];

      final dist = resolver.calculateSpeakingDistribution(segments);
      expect(dist['tutor'], equals(10.0));
      expect(dist['learner'], equals(5.0));
    });

    test('Empty segments returns empty list', () {
      expect(resolver.resolveOverlap([]), isEmpty);
    });
  });
}
