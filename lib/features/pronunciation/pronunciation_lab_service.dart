import '../../core/content_contract.dart';
import '../../core/srs_facets.dart';
import '../../features/audio/domain/entities/audio_playback_result.dart';
import '../../features/audio/domain/services/i_audio_runtime.dart';
import '../../features/audio/hybrid_pronunciation_service.dart';
import '../../models/learner.dart';
import '../../services/repository.dart';
import 'domain/pronunciation_models.dart';
import 'domain/services/pronunciation_signal_probe.dart';
import 'pronunciation_lab_engine.dart';
import 'pronunciation_signal_evaluator.dart';

final class PronunciationLabService<T extends LearningContent> {
  PronunciationLabService({
    required this.repository,
    required this.audioRuntime,
    required this.signalProbe,
    required this.languageCode,
    required Iterable<T> corpus,
  })  : _pronunciationAudio = HybridPronunciationService(
          audioRuntime: audioRuntime,
        ),
        engine = PronunciationLabEngine<T>(corpus);

  final LearnerRepository repository;
  final IAudioRuntime audioRuntime;
  final PronunciationSignalProbe signalProbe;
  final String languageCode;
  final HybridPronunciationService _pronunciationAudio;
  final PronunciationLabEngine<T> engine;

  List<PronunciationContrast> availableContrasts(
    Iterable<PronunciationContrast> catalog,
  ) =>
      engine.availableContrasts(catalog);

  PronunciationTrial<T>? buildTrial(
    PronunciationContrast contrast, {
    required int round,
  }) =>
      engine.buildTrial(contrast, round: round);

  List<PronunciationConfusionStat> confusionStats([LearnerState? state]) =>
      engine.confusionStats(state ?? repository.load());

  Future<AudioPlaybackResult> playTarget(
    PronunciationTrial<T> trial, {
    bool slow = false,
  }) =>
      _pronunciationAudio.play(
        conceptId: trial.target.item.id,
        text: trial.target.token,
        languageCode: languageCode,
        slow: slow,
      );

  Future<PronunciationPerceptionResult> answerPerception(
    PronunciationTrial<T> trial, {
    required String selectedToken,
    required int seconds,
  }) async {
    final result = engine.scorePerception(trial, selectedToken);
    await repository.recordFacet(
      item: trial.target.item,
      facetType: ReviewFacetType.pronunciation,
      variantKey: 'contrast:${trial.contrast.id}:perception',
      answer: selectedToken,
      correct: result.correct,
      seconds: seconds.clamp(0, 3600).toInt(),
      hinted: false,
    );
    return result;
  }

  Future<PronunciationProductionFeedback> captureProduction(
    PronunciationTrial<T> trial,
  ) async {
    if (!await signalProbe.requestPermission()) {
      return PronunciationSignalEvaluator.evaluate(
        capture: const PronunciationSignalCapture.unavailable(
          'microphone_permission_required',
        ),
        targetToken: trial.target.token,
      );
    }

    final capture = await signalProbe.capture(
      maxDuration: const Duration(milliseconds: 1700),
    );
    return PronunciationSignalEvaluator.evaluate(
      capture: capture,
      targetToken: trial.target.token,
    );
  }
}
