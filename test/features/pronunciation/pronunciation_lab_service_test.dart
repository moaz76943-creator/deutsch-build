import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_state.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/i_audio_runtime.dart';
import 'package:deutsch_bilarabi/features/pronunciation/domain/pronunciation_models.dart';
import 'package:deutsch_bilarabi/features/pronunciation/domain/services/pronunciation_signal_probe.dart';
import 'package:deutsch_bilarabi/features/pronunciation/pronunciation_lab_service.dart';
import 'package:deutsch_bilarabi/language/german/german_pronunciation_catalog.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';

final class _AudioRuntime implements IAudioRuntime {
  AudioRequest? lastRequest;

  @override
  Stream<AudioPlaybackState> get playbackStateStream =>
      Stream<AudioPlaybackState>.empty();

  @override
  Future<AudioPlaybackResult> play(AudioRequest request) async {
    lastRequest = request;
    return const AudioPlaybackResult.offlineTts();
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> shutdown() async {}
}

final class _SignalProbe implements PronunciationSignalProbe {
  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<PronunciationSignalCapture> capture({
    Duration maxDuration = const Duration(milliseconds: 1600),
  }) async => const PronunciationSignalCapture.available(
    PronunciationSignalFeatures(
      captureDurationMs: 1000,
      voicedDurationMs: 600,
      rms: .1,
      peak: .5,
      zeroCrossingRate: .06,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'uses Phase 10 audio and records pronunciation as its own SRS facet',
    () async {
      final prefs = await PreferencesService.instance();
      final repo = LearnerRepository(
        prefs,
        persistence: LearnerPersistence(
          prefs,
          'phase14_state',
          'phase14_favorites',
        ),
      );
      final audio = _AudioRuntime();
      const corpus = <ContentItem>[
        ContentItem(
          id: 'staat',
          german: 'Staat',
          arabic: 'دولة',
          sentence: '',
          sentenceAr: '',
          topic: 'test',
          skill: 'recall',
        ),
        ContentItem(
          id: 'stadt',
          german: 'die Stadt',
          arabic: 'المدينة',
          sentence: '',
          sentenceAr: '',
          topic: 'test',
          skill: 'recall',
        ),
      ];
      final service = PronunciationLabService<ContentItem>(
        repository: repo,
        audioRuntime: audio,
        signalProbe: _SignalProbe(),
        languageCode: 'de',
        corpus: corpus,
      );
      final contrast = service
          .availableContrasts(GermanPronunciationCatalog.contrasts)
          .single;
      final trial = service.buildTrial(contrast, round: 0)!;

      final playback = await service.playTarget(trial, slow: true);
      expect(playback.played, isTrue);
      expect(audio.lastRequest?.variant, AudioVariant.pronunciation);
      expect(audio.lastRequest?.conceptId, trial.target.item.id);

      final result = await service.answerPerception(
        trial,
        selectedToken: trial.target.token,
        seconds: 4,
      );
      expect(result.correct, isTrue);

      final state = repo.load();
      final card = state.reviewCardForFacet(
        trial.target.item.id,
        facetType: ReviewFacetType.pronunciation,
        variantKey: 'contrast:${trial.contrast.id}:perception',
      );
      expect(card, isNotNull);
      expect(state.attempts.last.facetType, ReviewFacetType.pronunciation);

      final production = await service.captureProduction(trial);
      expect(production.signalAvailable, isTrue);
      expect(production.phonemeAccuracyAvailable, isFalse);
    },
  );
}
