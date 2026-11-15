import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/duplex/full_duplex_dialogue_coordinator.dart';

void main() {
  group('FullDuplexDialogueCoordinator Suite', () {
    test('Triggers instant barge-in interrupt when learner speaks continuously for >= 120ms', () {
      final coordinator = FullDuplexDialogueCoordinator(bargeInThresholdMs: 120);

      coordinator.notifyTutorPlaybackStarted();
      expect(coordinator.isTutorSpeaking, isTrue);

      // Frame 1: 50ms learner speech
      var event = coordinator.processLearnerFrame(
        frameEnergy: 0.6,
        frameDurationMs: 50,
        vadSpeechDetected: true,
      );
      expect(event.shouldInterruptTutorAudio, isFalse);
      expect(coordinator.isTutorSpeaking, isTrue);

      // Frame 2: +50ms (total 100ms)
      event = coordinator.processLearnerFrame(
        frameEnergy: 0.6,
        frameDurationMs: 50,
        vadSpeechDetected: true,
      );
      expect(event.shouldInterruptTutorAudio, isFalse);

      // Frame 3: +50ms (total 150ms >= 120ms threshold) -> Barge-in interrupt!
      event = coordinator.processLearnerFrame(
        frameEnergy: 0.6,
        frameDurationMs: 50,
        vadSpeechDetected: true,
      );
      expect(event.shouldInterruptTutorAudio, isTrue);
      expect(coordinator.isTutorSpeaking, isFalse);
      expect(event.statusDescription, contains('إيقاف صوت المعلم فوراً'));
    });
  });
}
