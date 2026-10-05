import '../../../models/diagnostic_placement.dart';
import '../../../models/learner.dart';
import '../../../services/repository.dart';
import '../domain/placement_models.dart';
import '../domain/placement_repositories.dart';

final class LearnerPlacementProfileRepository
    implements PlacementProfileRepository {
  const LearnerPlacementProfileRepository(this.repository);

  final LearnerRepository repository;

  @override
  Future<void> applyResult(PlacementResult result, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    final state = await repository.reloadPersisted();
    final review = <String>{...state.review};
    final cards = <String, ReviewCard>{...state.reviewCards};

    for (final itemId in result.reviewItemIds) {
      final normalized = itemId.trim();
      if (normalized.isEmpty) continue;
      review.add(normalized);
      cards.putIfAbsent(
        normalized,
        () => ReviewCard(
          itemId: normalized,
          dueAt: now.add(
            Duration(days: result.initialReviewIntervalDays),
          ),
          difficulty: result.initialSrsDifficulty,
        ),
      );
    }

    final record = PlacementDiagnosticRecord(
      id: 'placement_${now.microsecondsSinceEpoch}',
      at: now,
      answered: result.answeredCount,
      scoredAnswers: result.answeredCount,
      score: result.proficiencyScore,
      confidence: result.confidence,
      band: switch (result.level) {
        PlacementLevel.a1 => DiagnosticPlacementBand.foundation,
        PlacementLevel.a2 => DiagnosticPlacementBand.developing,
        PlacementLevel.b1 => DiagnosticPlacementBand.strong,
        PlacementLevel.b2 => DiagnosticPlacementBand.strong,
      },
      dimensionScores: const <DiagnosticDimension, double>{},
      weakDimensions: const <DiagnosticDimension>[],
      reviewItemIds: result.reviewItemIds,
      curriculumStartLevel: result.level.label,
      recommendedStartTaskOrder: result.level.recommendedStartTaskOrder,
      learningGoal:
          (result.learningGoal ?? PlacementLearningGoal.general).name,
    );

    final history = <PlacementDiagnosticRecord>[
      record,
      ...state.placementHistory.where((entry) => entry.id != record.id),
    ].take(20).toList(growable: false);

    await repository.save(
      state.copyWith(
        review: review,
        reviewCards: cards,
        placementHistory: history,
      ),
    );
  }
}
