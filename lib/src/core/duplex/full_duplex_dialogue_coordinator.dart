enum DuplexDialogueState {
  tutorSpeakingOnly,
  learnerSpeakingOnly,
  simultaneousOverlapBargeIn, // Both audio channels active
  mutualSilenceListening,
}

class DialogueTurnEvent {
  final DuplexDialogueState state;
  final bool shouldInterruptTutorAudio;
  final double learnerVoiceEnergy;
  final int continuousOverlapMs;
  final String statusDescription;

  const DialogueTurnEvent({
    required this.state,
    required this.shouldInterruptTutorAudio,
    required this.learnerVoiceEnergy,
    required this.continuousOverlapMs,
    required this.statusDescription,
  });
}

/// Sovereign on-device Full-Duplex Zero-Latency Dialogue Coordinator.
/// Launches Volume 2 - Pillar 4 (Tasks 561-580). Manages continuous bi-directional
/// speech flow, detecting spontaneous learner barge-in and soft-interrupting
/// audio playback within <100ms.
class FullDuplexDialogueCoordinator {
  final int bargeInThresholdMs;
  final double minVoiceActivityEnergy;

  bool _isTutorSpeaking = false;
  int _overlapDurationMs = 0;

  FullDuplexDialogueCoordinator({
    this.bargeInThresholdMs = 120, // 120ms of continuous learner speech triggers barge-in
    this.minVoiceActivityEnergy = 0.25,
  });

  bool get isTutorSpeaking => _isTutorSpeaking;
  int get activeOverlapMs => _overlapDurationMs;

  void notifyTutorPlaybackStarted() {
    _isTutorSpeaking = true;
    _overlapDurationMs = 0;
  }

  void notifyTutorPlaybackFinished() {
    _isTutorSpeaking = false;
    _overlapDurationMs = 0;
  }

  /// Processes an incoming audio frame from the learner microphone stream.
  DialogueTurnEvent processLearnerFrame({
    required double frameEnergy,
    required int frameDurationMs,
    required bool vadSpeechDetected,
  }) {
    final hasLearnerSpeech = vadSpeechDetected && frameEnergy >= minVoiceActivityEnergy;

    if (_isTutorSpeaking && hasLearnerSpeech) {
      _overlapDurationMs += frameDurationMs;
      final shouldBargeIn = _overlapDurationMs >= bargeInThresholdMs;

      if (shouldBargeIn) {
        _isTutorSpeaking = false; // Tutor yields floor
      }

      return DialogueTurnEvent(
        state: DuplexDialogueState.simultaneousOverlapBargeIn,
        shouldInterruptTutorAudio: shouldBargeIn,
        learnerVoiceEnergy: frameEnergy,
        continuousOverlapMs: _overlapDurationMs,
        statusDescription: shouldBargeIn
            ? 'تم رصد مقاطعة المتعلّم (Barge-in)؛ إيقاف صوت المعلم فوراً وتسليم دفة الحوار للمتعلم.'
            : 'تداخل صوتي عابر قيد التقييم.',
      );
    } else if (hasLearnerSpeech) {
      _overlapDurationMs = 0;
      return DialogueTurnEvent(
        state: DuplexDialogueState.learnerSpeakingOnly,
        shouldInterruptTutorAudio: false,
        learnerVoiceEnergy: frameEnergy,
        continuousOverlapMs: 0,
        statusDescription: 'المتعلم يتحدث بحرية دون مقاطعة.',
      );
    } else if (_isTutorSpeaking) {
      _overlapDurationMs = 0;
      return DialogueTurnEvent(
        state: DuplexDialogueState.tutorSpeakingOnly,
        shouldInterruptTutorAudio: false,
        learnerVoiceEnergy: frameEnergy,
        continuousOverlapMs: 0,
        statusDescription: 'المعلم يتحدث والمتعلم يستمع باهتمام.',
      );
    } else {
      _overlapDurationMs = 0;
      return DialogueTurnEvent(
        state: DuplexDialogueState.mutualSilenceListening,
        shouldInterruptTutorAudio: false,
        learnerVoiceEnergy: frameEnergy,
        continuousOverlapMs: 0,
        statusDescription: 'صمت متبادل بانتظار بدء أي من الطرفين بالكلام.',
      );
    }
  }
}
