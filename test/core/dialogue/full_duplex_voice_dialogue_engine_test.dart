import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/full_duplex_voice_dialogue_engine.dart';

void main() {
  group('FullDuplexVoiceDialogueEngine Tests', () {
    test('Detects learner speech and switches from idle to listening', () {
      final engine = FullDuplexVoiceDialogueEngine();
      expect(engine.currentState, equals(VoiceChannelState.idle));

      const speechFrame = AudioStreamFrame(pcmSamples: [100, 200], rmsEnergy: 0.15, isSpeechActive: true);
      final state = engine.processInboundAudioFrame(speechFrame);

      expect(state, equals(VoiceChannelState.listeningToLearner));
    });

    test('Triggers instant barge-in interruption when learner speaks during tutor playback', () {
      final engine = FullDuplexVoiceDialogueEngine();
      engine.notifyTutorSpeakingStarted();
      expect(engine.currentState, equals(VoiceChannelState.tutorSpeaking));

      // Learner interrupts with high energy audio
      const bargeInFrame = AudioStreamFrame(pcmSamples: [500, 600], rmsEnergy: 0.25, isSpeechActive: true);
      final state = engine.processInboundAudioFrame(bargeInFrame);

      expect(state, equals(VoiceChannelState.bargeInInterrupted));
      expect(engine.isPlaybackInterrupted, isTrue);
    });

    test('Triggers learnerSilenceDetected after reaching silence timeout threshold', () {
      final engine = FullDuplexVoiceDialogueEngine(silenceTimeoutMs: 150); // 3 frames of 50ms
      engine.processInboundAudioFrame(const AudioStreamFrame(pcmSamples: [100], rmsEnergy: 0.12, isSpeechActive: true));
      expect(engine.currentState, equals(VoiceChannelState.listeningToLearner));

      const silentFrame = AudioStreamFrame(pcmSamples: [0], rmsEnergy: 0.01, isSpeechActive: false);
      engine.processInboundAudioFrame(silentFrame); // 50ms
      engine.processInboundAudioFrame(silentFrame); // 100ms
      final state = engine.processInboundAudioFrame(silentFrame); // 150ms -> triggers

      expect(state, equals(VoiceChannelState.learnerSilenceDetected));
    });
  });
}
