import 'dart:async';

import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/offline_audio_runtime.dart';
import 'package:deutsch_bilarabi/features/session/universal_session_orchestrator.dart';
import 'package:deutsch_bilarabi/language/german/german_speech_profile.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stress_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rapid learning-card and audio taps serialize without controller collapse', () async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final prefs = await PreferencesService.instance();
    final persistence = LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );
    final repository = LearnerRepository(prefs, persistence: persistence);
    final haptics = NoopSessionHaptics();
    final session = UniversalSessionOrchestrator(
      repository: repository,
      haptics: haptics,
    );

    final engine = StressTtsEngine();
    final runtime = OfflineAudioRuntime(
      speechProfile: const GermanSpeechProfile(),
      ttsEngine: engine,
    );
    final controller = SafeTtsController(
      runtime: runtime,
      profile: const GermanSpeechProfile(),
    );

    final streamClosed = Completer<void>();
    final subscription = runtime.playbackStateStream.listen(
      (_) {},
      onDone: () => streamClosed.complete(),
    );

    const count = 120;
    const item = StressLearningContent(id: 'stress-race-card');

    final reviewFutures = List<Future<SessionStateSnapshot>>.generate(
      count,
      (index) => session.record(
        SessionReviewInput<StressLearningContent>(
          item: item,
          answer: index.isEven ? 'Haus' : '',
          correct: index.isEven,
          seconds: index % 2 == 0 ? 1 : 3601,
          hinted: index % 3 == 0,
        ),
      ),
      growable: false,
    );
    final audioFutures = List<Future<void>>.generate(
      count,
      (index) => safeSpeak(controller, 'Haus $index'),
      growable: false,
    );

    final reviewResults = await Future.wait(reviewFutures);
    await Future.wait(audioFutures);

    expect(reviewResults, hasLength(count));
    expect(session.state.answered, count);
    expect(session.state.correct, count ~/ 2);
    expect(haptics.correctSignals, count ~/ 2);
    expect(haptics.incorrectSignals, count ~/ 2);

    final persisted = await repository.reloadPersisted();
    expect(persisted.attempts, hasLength(count));
    expect(persisted.attempts.every((attempt) => attempt.seconds <= 3600), isTrue);

    expect(engine.speakCalls, count);
    expect(engine.maxConcurrentSpeaks, 1);
    expect(engine.activeSpeaks, 0);
    expect(controller.isBusy, isFalse);

    await safeTtsShutdown(controller);
    await streamClosed.future;
    await subscription.cancel();

    expect(controller.isDisposed, isTrue);
    expect(engine.shutdownCalls, 1);

    final afterShutdown = await runtime.play(
      const AudioRequest(text: 'ignored', languageCode: 'de'),
    );
    expect(afterShutdown.source, AudioPlaybackSource.unavailable);
    expect(afterShutdown.reason, 'audio_runtime_closed');
  });

  test('raw audio-runtime burst supersedes stale requests and completes every future', () async {
    final engine = StressTtsEngine();
    final runtime = OfflineAudioRuntime(
      speechProfile: const GermanSpeechProfile(),
      ttsEngine: engine,
    );

    const count = 250;
    final futures = List<Future<AudioPlaybackResult>>.generate(
      count,
      (index) => runtime.play(
        AudioRequest(text: 'Wort $index', languageCode: 'de'),
      ),
      growable: false,
    );

    final results = await Future.wait(futures);

    expect(results, hasLength(count));
    expect(
      results.where((result) => result.reason == 'audio_request_superseded'),
      hasLength(count - 1),
    );
    expect(results.last.source, AudioPlaybackSource.offlineTts);
    expect(engine.speakCalls, 1);
    expect(engine.maxConcurrentSpeaks, 1);

    await runtime.shutdown();
    expect(engine.shutdownCalls, 1);
  });
}
