import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_state.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/i_audio_runtime.dart';
import 'package:deutsch_bilarabi/features/commute/domain/commute_models.dart';
import 'package:deutsch_bilarabi/features/commute/hands_free_commute_service.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';

final class _FakeAudioRuntime implements IAudioRuntime {
  _FakeAudioRuntime(this.label, this.events, {this.failureReason});

  final String label;
  final List<String> events;
  final String? failureReason;

  @override
  Stream<AudioPlaybackState> get playbackStateStream =>
      Stream<AudioPlaybackState>.empty();

  @override
  Future<AudioPlaybackResult> play(AudioRequest request) async {
    events.add('$label:${request.languageCode}:${request.text}');
    final reason = failureReason;
    return reason == null
        ? const AudioPlaybackResult.offlineTts()
        : AudioPlaybackResult.unavailable(reason);
  }

  @override
  Future<void> stop() async {
    events.add('$label:stop');
  }

  @override
  Future<void> shutdown() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<LearnerRepository> repository(String key) async {
    final prefs = await PreferencesService.instance();
    return LearnerRepository(
      prefs,
      persistence: LearnerPersistence(prefs, key, '${key}_favorites'),
    );
  }

  const item = ContentItem(
    id: 'w0638',
    german: 'Staat',
    arabic: 'دولة',
    sentence: 'Der Staat unterstützt die Schule.',
    sentenceAr: 'الدولة تدعم المدرسة.',
    topic: 'society',
    skill: 'recall',
  );

  test('plays target term then Arabic meaning then target example', () async {
    final repo = await repository('commute_sequence');
    final events = <String>[];
    final service = HandsFreeCommuteService<ContentItem>(
      repository: repo,
      targetAudioRuntime: _FakeAudioRuntime('target', events),
      sourceAudioRuntime: _FakeAudioRuntime('source', events),
      targetLanguageCode: 'de',
      sourceLanguageCode: 'ar',
      corpus: const <ContentItem>[item],
      interSegmentPause: Duration.zero,
    );
    final review = CommuteReviewItem<ContentItem>(
      item: item,
      facetType: ReviewFacetType.listening,
      variantKey: null,
      dueAt: DateTime.utc(2026, 10, 2),
    );

    final result = await service.play(review);

    expect(result.completed, isTrue);
    expect(events, <String>[
      'target:de:Staat',
      'source:ar:دولة',
      'target:de:Der Staat unterstützt die Schule.',
    ]);
  });

  test('fails explicitly when one audio runtime is unavailable', () async {
    final repo = await repository('commute_unavailable');
    final events = <String>[];
    final service = HandsFreeCommuteService<ContentItem>(
      repository: repo,
      targetAudioRuntime: _FakeAudioRuntime('target', events),
      sourceAudioRuntime: _FakeAudioRuntime(
        'source',
        events,
        failureReason: 'offline_tts_voice_unavailable',
      ),
      targetLanguageCode: 'de',
      sourceLanguageCode: 'ar',
      corpus: const <ContentItem>[item],
      interSegmentPause: Duration.zero,
    );
    final review = CommuteReviewItem<ContentItem>(
      item: item,
      facetType: ReviewFacetType.meaningRecall,
      variantKey: null,
      dueAt: DateTime.utc(2026, 10, 2),
    );

    final result = await service.play(review);

    expect(result.completed, isFalse);
    expect(result.failed, isTrue);
    expect(result.stage, CommutePlaybackStage.sourceMeaning);
    expect(result.reason, 'offline_tts_voice_unavailable');
    expect(events, <String>['target:de:Staat', 'source:ar:دولة']);
  });

  test('known and unknown actions write the exact Phase 11 facet', () async {
    final repo = await repository('commute_srs');
    final now = DateTime.utc(2026, 10, 2, 18);
    final key = const ReviewFacetKey(
      conceptId: 'w0638',
      facetType: ReviewFacetType.listening,
    ).storageKey;
    await repo.save(
      LearnerState(
        reviewCards: <String, ReviewCard>{
          key: ReviewCard(
            itemId: item.id,
            facetType: ReviewFacetType.listening,
            dueAt: now,
          ),
        },
        updatedAt: now,
      ),
    );

    final service = HandsFreeCommuteService<ContentItem>(
      repository: repo,
      targetAudioRuntime: _FakeAudioRuntime('target', <String>[]),
      sourceAudioRuntime: _FakeAudioRuntime('source', <String>[]),
      targetLanguageCode: 'de',
      sourceLanguageCode: 'ar',
      corpus: const <ContentItem>[item],
      interSegmentPause: Duration.zero,
    );
    final pending = service.pendingQueue(
      now: now.add(const Duration(seconds: 1)),
    );
    expect(pending, hasLength(1));

    await service.recordReview(
      pending.single,
      known: false,
      seconds: 7,
      at: now.add(const Duration(seconds: 2)),
    );

    final state = repo.load();
    expect(state.attempts.last.facetType, ReviewFacetType.listening);
    expect(state.attempts.last.correct, isFalse);
    expect(
      state
          .reviewCardForFacet(item.id, facetType: ReviewFacetType.listening)
          ?.lastReviewedAt,
      isNotNull,
    );
  });
}
