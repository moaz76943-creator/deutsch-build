import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/emotional_speech_synthesizer.dart';

void main() {
  test('Resolves emotion acoustic parameters with higher pitch for encouragement', () {
    const synth = EmotionalSpeechSynthesizer();
    final excited = synth.resolveParameters(SpeechEmotion.encouragingExcited);
    final whisper = synth.resolveParameters(SpeechEmotion.calmWhisper);
    expect(excited.pitchScale, greaterThan(1.1));
    expect(whisper.whisperBreathiness, greaterThan(0.2));
  });
}
