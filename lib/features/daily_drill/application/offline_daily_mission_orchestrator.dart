import '../../../core/content_contract.dart';
import '../../../core/progress/pair_progress_models.dart';
import '../../../core/srs_facets.dart';
import '../../../services/repository.dart';
import '../../session/universal_session_orchestrator.dart';

enum OfflineDailyMissionItemKind {
  dueReview,
  grammar,
  vocabulary,
  reinforcement,
  discovery,
}

final class OfflineDailyMissionItem {
  const OfflineDailyMissionItem({
    required this.item,
    required this.kind,
    required this.facetType,
    this.variantKey,
    this.dueAt,
    this.incorrectCount = 0,
    this.successRate = 0,
  });

  final LearningContent item;
  final OfflineDailyMissionItemKind kind;
  final ReviewFacetType facetType;
  final String? variantKey;
  final DateTime? dueAt;
  final int incorrectCount;
  final double successRate;

  String get reviewKey => ReviewFacetKey(
        conceptId: item.id,
        facetType: facetType,
        variantKey: variantKey,
      ).storageKey;
}

final class OfflineDailyMissionPlan {
  OfflineDailyMissionPlan({
    required this.id,
    required this.pairKey,
    required this.generatedAtUtc,
    required this.dailyTarget,
    required this.completedToday,
    required Iterable<OfflineDailyMissionItem> items,
  }) : items = List<OfflineDailyMissionItem>.unmodifiable(items) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (pairKey.trim().isEmpty) {
      throw ArgumentError.value(pairKey, 'pairKey', 'must not be empty');
    }
    if (dailyTarget < 1 || dailyTarget > 12) {
      throw ArgumentError.value(
        dailyTarget,
        'dailyTarget',
        'must be 1..12',
      );
    }
    if (completedToday < 0 || completedToday > dailyTarget) {
      throw ArgumentError.value(
        completedToday,
        'completedToday',
        'must be within daily target',
      );
    }
    if (this.items.length > remainingTarget) {
      throw ArgumentError(
        'mission items cannot exceed the remaining daily target',
      );
    }
  }

  final String id;
  final String pairKey;
  final DateTime generatedAtUtc;
  final int dailyTarget;
  final int completedToday;
  final List<OfflineDailyMissionItem> items;

  int get remainingTarget => dailyTarget - completedToday;
  bool get isCompleted => remainingTarget == 0;
  bool get isEmpty => items.isEmpty;
}

final class OfflineDailyMissionOrchestrator {
  const OfflineDailyMissionOrchestrator({
    required LearnerRepository repository,
    required UniversalSessionOrchestrator sessionOrchestrator,
  })  : _repository = repository,
        _sessionOrchestrator = sessionOrchestrator;

  final LearnerRepository _repository;
  final UniversalSessionOrchestrator _sessionOrchestrator;

  Future<OfflineDailyMissionPlan> build({
    required Iterable<LearningContent> corpus,
    DateTime? now,
    int dailyTarget = 6,
  }) async {
    final safeTarget = dailyTarget.clamp(1, 12).toInt();
    final generatedAtUtc = (now ?? DateTime.now()).toUtc();
    final pairSnapshot = await _repository.loadPairProgress();

    final dayStart = DateTime.utc(
      generatedAtUtc.year,
      generatedAtUtc.month,
      generatedAtUtc.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));

    final reviewedToday = <String>{
      for (final card in pairSnapshot.cards)
        if (_isWithinUtcDay(card.lastReviewedAt, dayStart, dayEnd))
          card.cardId,
    };
    final completedToday =
        reviewedToday.length.clamp(0, safeTarget).toInt();
    final remainingTarget = safeTarget - completedToday;

    final contentById = <String, LearningContent>{};
    final corpusInOrder = <LearningContent>[];
    for (final item in corpus) {
      final id = item.id.trim();
      if (id.isEmpty || contentById.containsKey(id)) continue;
      contentById[id] = item;
      corpusInOrder.add(item);
    }

    if (remainingTarget == 0 || contentById.isEmpty) {
      return OfflineDailyMissionPlan(
        id: _missionId(pairSnapshot, dayStart),
        pairKey: pairSnapshot.pairKey,
        generatedAtUtc: generatedAtUtc,
        dailyTarget: safeTarget,
        completedToday: completedToday,
        items: const <OfflineDailyMissionItem>[],
      );
    }

    final candidates = <_MissionCandidate>[];
    final progressedConcepts = <String>{};

    for (final card in pairSnapshot.cards) {
      final review = card.reviewCard;
      if (review == null || !review.facetKey.isValid) continue;
      progressedConcepts.add(review.itemId);

      final item = contentById[review.itemId];
      if (item == null || reviewedToday.contains(card.cardId)) {
        continue;
      }

      final dueAtUtc = review.dueAt.toUtc();
      final isDue = !dueAtUtc.isAfter(generatedAtUtc);
      final weak = card.incorrectCount > card.correctCount ||
          review.failures > review.successes ||
          review.successRate < 0.75;

      if (!isDue && !weak) continue;

      candidates.add(
        _MissionCandidate(
          item: item,
          kind: isDue
              ? OfflineDailyMissionItemKind.dueReview
              : _kindForSkill(item.skill),
          facetType: review.facetType,
          variantKey: review.variantKey,
          dueAt: dueAtUtc,
          incorrectCount: card.incorrectCount,
          successRate: review.successRate,
          priority: isDue ? 0 : 1,
        ),
      );
    }

    candidates.sort(_compareCandidates);

    final selected = <OfflineDailyMissionItem>[];
    final selectedReviewKeys = <String>{};

    void addCandidate(_MissionCandidate candidate) {
      if (selected.length >= remainingTarget) return;
      final key = candidate.reviewKey;
      if (!selectedReviewKeys.add(key)) return;
      selected.add(candidate.toMissionItem());
    }

    for (final candidate in candidates.where((item) => item.priority == 0)) {
      addCandidate(candidate);
      if (selected.length >= remainingTarget) break;
    }

    if (selected.length < remainingTarget) {
      _addPreferredSkill(
        selected: selected,
        selectedReviewKeys: selectedReviewKeys,
        candidates: candidates,
        skill: 'grammar',
        remainingTarget: remainingTarget,
      );
    }
    if (selected.length < remainingTarget) {
      _addPreferredSkill(
        selected: selected,
        selectedReviewKeys: selectedReviewKeys,
        candidates: candidates,
        skill: 'vocabulary',
        remainingTarget: remainingTarget,
      );
    }

    for (final candidate in candidates.where((item) => item.priority != 0)) {
      addCandidate(candidate);
      if (selected.length >= remainingTarget) break;
    }

    if (selected.length < remainingTarget) {
      _addFreshSkill(
        selected: selected,
        selectedReviewKeys: selectedReviewKeys,
        corpus: corpusInOrder,
        progressedConcepts: progressedConcepts,
        skill: 'grammar',
        remainingTarget: remainingTarget,
      );
    }
    if (selected.length < remainingTarget) {
      _addFreshSkill(
        selected: selected,
        selectedReviewKeys: selectedReviewKeys,
        corpus: corpusInOrder,
        progressedConcepts: progressedConcepts,
        skill: 'vocabulary',
        remainingTarget: remainingTarget,
      );
    }

    if (selected.length < remainingTarget) {
      for (final item in corpusInOrder) {
        if (progressedConcepts.contains(item.id)) continue;
        final missionItem = OfflineDailyMissionItem(
          item: item,
          kind: OfflineDailyMissionItemKind.discovery,
          facetType: ReviewFacetType.meaningRecall,
        );
        if (!selectedReviewKeys.add(missionItem.reviewKey)) continue;
        selected.add(missionItem);
        if (selected.length >= remainingTarget) break;
      }
    }

    return OfflineDailyMissionPlan(
      id: _missionId(pairSnapshot, dayStart),
      pairKey: pairSnapshot.pairKey,
      generatedAtUtc: generatedAtUtc,
      dailyTarget: safeTarget,
      completedToday: completedToday,
      items: selected,
    );
  }

  Future<SessionStateSnapshot> record({
    required OfflineDailyMissionItem missionItem,
    required String answer,
    required bool correct,
    required int seconds,
    bool hinted = false,
  }) {
    return _sessionOrchestrator.record(
      SessionReviewInput<LearningContent>(
        item: missionItem.item,
        answer: answer,
        correct: correct,
        seconds: seconds.clamp(1, 3600).toInt(),
        hinted: hinted,
        facetType: missionItem.facetType,
        variantKey: missionItem.variantKey,
        skillOverride: missionItem.item.skill,
      ),
    );
  }

  static void _addPreferredSkill({
    required List<OfflineDailyMissionItem> selected,
    required Set<String> selectedReviewKeys,
    required List<_MissionCandidate> candidates,
    required String skill,
    required int remainingTarget,
  }) {
    final normalizedSkill = skill.trim().toLowerCase();
    final alreadyPresent = selected.any(
      (item) => item.item.skill.trim().toLowerCase() == normalizedSkill,
    );
    if (alreadyPresent) return;

    for (final candidate in candidates) {
      if (candidate.item.skill.trim().toLowerCase() != normalizedSkill) {
        continue;
      }
      if (!selectedReviewKeys.add(candidate.reviewKey)) continue;
      selected.add(candidate.toMissionItem());
      if (selected.length >= remainingTarget) return;
      return;
    }
  }

  static void _addFreshSkill({
    required List<OfflineDailyMissionItem> selected,
    required Set<String> selectedReviewKeys,
    required List<LearningContent> corpus,
    required Set<String> progressedConcepts,
    required String skill,
    required int remainingTarget,
  }) {
    final normalizedSkill = skill.trim().toLowerCase();
    final alreadyPresent = selected.any(
      (item) => item.item.skill.trim().toLowerCase() == normalizedSkill,
    );
    if (alreadyPresent) return;

    for (final item in corpus) {
      if (progressedConcepts.contains(item.id) ||
          item.skill.trim().toLowerCase() != normalizedSkill) {
        continue;
      }

      final missionItem = OfflineDailyMissionItem(
        item: item,
        kind: _kindForSkill(item.skill),
        facetType: ReviewFacetType.meaningRecall,
      );
      if (!selectedReviewKeys.add(missionItem.reviewKey)) continue;
      selected.add(missionItem);
      if (selected.length >= remainingTarget) return;
      return;
    }
  }

  static OfflineDailyMissionItemKind _kindForSkill(String rawSkill) {
    switch (rawSkill.trim().toLowerCase()) {
      case 'grammar':
        return OfflineDailyMissionItemKind.grammar;
      case 'vocabulary':
        return OfflineDailyMissionItemKind.vocabulary;
      default:
        return OfflineDailyMissionItemKind.reinforcement;
    }
  }

  static int _compareCandidates(
    _MissionCandidate a,
    _MissionCandidate b,
  ) {
    final priority = a.priority.compareTo(b.priority);
    if (priority != 0) return priority;

    final dueA = a.dueAt?.microsecondsSinceEpoch ?? 0;
    final dueB = b.dueAt?.microsecondsSinceEpoch ?? 0;
    final due = dueA.compareTo(dueB);
    if (due != 0) return due;

    final incorrect = b.incorrectCount.compareTo(a.incorrectCount);
    if (incorrect != 0) return incorrect;

    final success = a.successRate.compareTo(b.successRate);
    if (success != 0) return success;

    return a.reviewKey.compareTo(b.reviewKey);
  }

  static bool _isWithinUtcDay(
    DateTime value,
    DateTime dayStart,
    DateTime dayEnd,
  ) {
    final utc = value.toUtc();
    return !utc.isBefore(dayStart) && utc.isBefore(dayEnd);
  }

  static String _missionId(
    PairProgressSnapshot snapshot,
    DateTime dayStart,
  ) {
    final date = dayStart.toIso8601String().substring(0, 10);
    return 'daily:${snapshot.pairKey}:$date';
  }
}

final class _MissionCandidate {
  const _MissionCandidate({
    required this.item,
    required this.kind,
    required this.facetType,
    required this.variantKey,
    required this.dueAt,
    required this.incorrectCount,
    required this.successRate,
    required this.priority,
  });

  final LearningContent item;
  final OfflineDailyMissionItemKind kind;
  final ReviewFacetType facetType;
  final String? variantKey;
  final DateTime? dueAt;
  final int incorrectCount;
  final double successRate;
  final int priority;

  String get reviewKey => ReviewFacetKey(
        conceptId: item.id,
        facetType: facetType,
        variantKey: variantKey,
      ).storageKey;

  OfflineDailyMissionItem toMissionItem() {
    return OfflineDailyMissionItem(
      item: item,
      kind: kind,
      facetType: facetType,
      variantKey: variantKey,
      dueAt: dueAt,
      incorrectCount: incorrectCount,
      successRate: successRate,
    );
  }
}
