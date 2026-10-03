import '../../core/content_contract.dart';
import '../../features/audio/domain/entities/audio_request.dart';
import '../../features/audio/domain/services/i_audio_runtime.dart';
import '../../models/learner.dart';
import '../../services/repository.dart';
import 'commute_review_queue.dart';
import 'domain/commute_models.dart';

final class HandsFreeCommuteService<T extends LearningContent> {
  HandsFreeCommuteService({
    required this.repository,
    required this.targetAudioRuntime,
    required this.sourceAudioRuntime,
    required this.targetLanguageCode,
    required this.sourceLanguageCode,
    required Iterable<T> corpus,
    this.interSegmentPause = const Duration(milliseconds: 700),
  }) : queueBuilder = CommuteReviewQueueBuilder<T>(corpus);

  final LearnerRepository repository;
  final IAudioRuntime targetAudioRuntime;
  final IAudioRuntime sourceAudioRuntime;
  final String targetLanguageCode;
  final String sourceLanguageCode;
  final Duration interSegmentPause;
  final CommuteReviewQueueBuilder<T> queueBuilder;

  int _generation = 0;
  bool _paused = false;

  List<CommuteReviewItem<T>> pendingQueue({
    LearnerState? state,
    DateTime? now,
    int limit = 50,
  }) =>
      queueBuilder.build(state ?? repository.load(), now: now, limit: limit);

  Future<CommutePlaybackReport> play(CommuteReviewItem<T> review) async {
    final generation = ++_generation;
    _paused = false;

    final term = await _playSegment(
      generation: generation,
      runtime: targetAudioRuntime,
      request: AudioRequest(
        text: review.item.sourceText,
        languageCode: targetLanguageCode,
        conceptId: review.item.id,
        variant: AudioVariant.word,
      ),
      stage: CommutePlaybackStage.targetTerm,
    );
    if (term != null) return term;
    if (!await _betweenSegments(generation)) {
      return const CommutePlaybackReport.cancelled();
    }

    final meaning = await _playSegment(
      generation: generation,
      runtime: sourceAudioRuntime,
      request: AudioRequest(
        text: review.item.translationText,
        languageCode: sourceLanguageCode,
        conceptId: review.item.id,
        variant: AudioVariant.word,
      ),
      stage: CommutePlaybackStage.sourceMeaning,
    );
    if (meaning != null) return meaning;
    if (!await _betweenSegments(generation)) {
      return const CommutePlaybackReport.cancelled();
    }

    final example = await _playSegment(
      generation: generation,
      runtime: targetAudioRuntime,
      request: AudioRequest(
        text: review.item.exampleText,
        languageCode: targetLanguageCode,
        conceptId: review.item.id,
        variant: AudioVariant.sentence,
      ),
      stage: CommutePlaybackStage.targetExample,
    );
    if (example != null) return example;

    return generation == _generation && !_paused
        ? const CommutePlaybackReport.completed()
        : const CommutePlaybackReport.cancelled();
  }

  Future<void> pause() async {
    _paused = true;
    ++_generation;
    await Future.wait<void>(<Future<void>>[
      targetAudioRuntime.stop(),
      sourceAudioRuntime.stop(),
    ]);
  }

  Future<void> recordReview(
    CommuteReviewItem<T> review, {
    required bool known,
    required int seconds,
    DateTime? at,
  }) =>
      repository.recordFacet(
        item: review.item,
        facetType: review.facetType,
        variantKey: review.variantKey,
        answer: known ? 'commute_known' : 'commute_unknown',
        correct: known,
        seconds: seconds.clamp(0, 3600).toInt(),
        hinted: false,
        at: at,
      );

  Future<CommutePlaybackReport?> _playSegment({
    required int generation,
    required IAudioRuntime runtime,
    required AudioRequest request,
    required CommutePlaybackStage stage,
  }) async {
    if (generation != _generation || _paused) {
      return const CommutePlaybackReport.cancelled();
    }
    final result = await runtime.play(request);
    if (generation != _generation || _paused) {
      return const CommutePlaybackReport.cancelled();
    }
    if (!result.played) {
      return CommutePlaybackReport.failed(
        stage,
        result.reason ?? 'audio_runtime_unavailable',
      );
    }
    return null;
  }

  Future<bool> _betweenSegments(int generation) async {
    if (generation != _generation || _paused) return false;
    if (interSegmentPause.inMicroseconds > 0) {
      await Future<void>.delayed(interSegmentPause);
    }
    return generation == _generation && !_paused;
  }
}
