import 'package:deutsch_bilarabi/core/language_agents/sys_pronunciation_speech_practice/audio_asset_player.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_pronunciation_speech_practice/speech_models.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_pronunciation_speech_practice/speech_practice_hub.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_pronunciation_speech_practice/voice_recognition_engine.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_state.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/i_audio_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeAudioRuntime implements IAudioRuntime {
  AudioRequest? lastRequest;

  @override
  Stream<AudioPlaybackState> get playbackStateStream =>
      const Stream<AudioPlaybackState>.empty();

  @override
  Future<AudioPlaybackResult> play(AudioRequest request) async {
    lastRequest = request;
    return const AudioPlaybackResult.recorded();
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> shutdown() async {}
}

void main() {
  test('audio player binds concept id and pronunciation variant to runtime', () async {
    final runtime = _FakeAudioRuntime();
    final player = SpeechPracticeAudioPlayer(runtime: runtime);

    const prompt = SpeechPracticePrompt(
      id: 'greeting-hello',
      text: 'Guten Tag',
      languageCode: 'de',
      localeId: 'de_DE',
      conceptId: 'greeting-hello',
      acceptedForms: <String>['Guten Tag!'],
    );

    await player.play(prompt, rate: 0.75);

    expect(runtime.lastRequest?.text, 'Guten Tag');
    expect(runtime.lastRequest?.languageCode, 'de');
    expect(runtime.lastRequest?.conceptId, 'greeting-hello');
    expect(runtime.lastRequest?.variant.name, 'pronunciation');
    expect(runtime.lastRequest?.rate, 0.75);
  });

  test('voice matcher scores exact and accepted alternative transcripts', () {
    const engine = VoiceRecognitionEngine();

    const prompt = SpeechPracticePrompt(
      id: 'thanks',
      text: 'Vielen Dank',
      languageCode: 'de',
      localeId: 'de_DE',
      conceptId: 'thanks',
      acceptedForms: <String>['Danke schön'],
    );

    final exact = engine.compare(prompt: prompt, recognizedText: 'Vielen Dank!');
    final alternative =
        engine.compare(prompt: prompt, recognizedText: 'Danke schön');
    final weak = engine.compare(prompt: prompt, recognizedText: 'Guten Morgen');

    expect(exact.isExact, isTrue);
    expect(alternative.isAccepted, isTrue);
    expect(weak.isAccepted, isFalse);
    expect(weak.similarity, lessThan(alternative.similarity));
  });

  test('speech hub combines playback and transcript evaluation', () async {
    final runtime = _FakeAudioRuntime();
    final hub = SpeechPracticeHub(audioRuntime: runtime);

    const prompt = SpeechPracticePrompt(
      id: 'appointment',
      text: 'Ich möchte einen Termin vereinbaren',
      languageCode: 'de',
      localeId: 'de_DE',
      conceptId: 'appointment',
    );

    final playback = await hub.play(prompt);
    final evaluation = hub.evaluateTranscript(
      prompt: prompt,
      recognizedText: 'Ich möchte einen Termin vereinbaren.',
    );

    expect(playback.played, isTrue);
    expect(evaluation.isAccepted, isTrue);
    expect(evaluation.feedbackCode, 'exact_match');
  });
}
