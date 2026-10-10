import 'diagnostic_placement.dart';
import 'package:deutsch_bilarabi/core/srs_facets.dart';

class Attempt {
  final String id, itemId, skill, answer;
  final bool correct, hinted;
  final int seconds;
  final DateTime at;
  final ReviewFacetType facetType;
  final String? variantKey;
  const Attempt({
    required this.id,
    required this.itemId,
    required this.skill,
    required this.answer,
    required this.correct,
    required this.hinted,
    required this.seconds,
    required this.at,
    this.facetType = ReviewFacetType.meaningRecall,
    this.variantKey,
  });
  bool get isMeaningFacet =>
      facetType == ReviewFacetType.meaningRecall &&
      ReviewFacetKey.normalizeVariant(variantKey).isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'skill': skill,
        'answer': answer,
        'correct': correct,
        'hinted': hinted,
        'seconds': seconds,
        'at': at.toIso8601String(),
        'facetType': facetType.wireName,
        'variantKey': ReviewFacetKey.normalizeVariant(variantKey),
      };
  factory Attempt.fromJson(Map<String, dynamic> j) => Attempt(
        id: j['id'] ?? '',
        itemId: j['itemId'] ?? '',
        skill: j['skill'] ?? 'recall',
        answer: j['answer'] ?? '',
        correct: j['correct'] == true,
        hinted: j['hinted'] == true,
        seconds: (j['seconds'] as num?)?.toInt() ?? 5,
        at: DateTime.tryParse(j['at'] ?? '') ?? DateTime.now(),
        facetType: ReviewFacetType.fromWire(j['facetType']?.toString()),
        variantKey:
            ReviewFacetKey.normalizeVariant(j['variantKey']?.toString()),
      );
}

class AssessmentHistory {
  final String id;
  final DateTime at;
  final double score;
  final List<String> weakSkills;
  final int answered;
  const AssessmentHistory({
    required this.id,
    required this.at,
    required this.score,
    required this.weakSkills,
    required this.answered,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'at': at.toIso8601String(),
        'score': score.clamp(0, 100),
        'weakSkills': weakSkills.take(8).toList(),
        'answered': answered.clamp(0, 100),
      };
  factory AssessmentHistory.fromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    var safeAt = DateTime.tryParse(j['at']?.toString() ?? '') ?? now;
    if (safeAt.isAfter(now.add(const Duration(days: 1)))) safeAt = now;
    if (safeAt.isBefore(DateTime(2000))) safeAt = now;
    final rawId = (j['id'] ?? '').toString().trim();
    return AssessmentHistory(
      id: rawId.substring(0, rawId.length.clamp(0, 160).toInt()),
      at: safeAt,
      score: (((j['score'] as num?)?.toDouble() ?? 0).clamp(0, 100)).toDouble(),
      weakSkills: (j['weakSkills'] is List
          ? (j['weakSkills'] as List)
              .whereType<String>()
              .map((x) => x.trim())
              .where((x) => x.isNotEmpty)
              .take(8)
              .toList()
          : const <String>[]),
      answered: (((j['answered'] as num?)?.toInt() ?? 0).clamp(0, 100)).toInt(),
    );
  }
}

enum MemoryState { newCard, learning, relearning, young, mature }

class ReviewCard {
  final String itemId;
  final ReviewFacetType facetType;
  final String? variantKey;
  final int repetitions, intervalDays, lapses, successes, failures;
  final double difficulty, stabilityDays;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;

  const ReviewCard({
    required this.itemId,
    this.facetType = ReviewFacetType.meaningRecall,
    this.variantKey,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.lapses = 0,
    this.successes = 0,
    this.failures = 0,
    this.difficulty = 1.3,
    this.stabilityDays = 0,
    required this.dueAt,
    this.lastReviewedAt,
  });

  String get conceptId => itemId;

  ReviewFacetKey get facetKey => ReviewFacetKey(
        conceptId: itemId,
        facetType: facetType,
        variantKey: variantKey,
      );

  String get storageKey => facetKey.storageKey;

  MemoryState get memoryState {
    if (repetitions <= 0 && lapses > 0) return MemoryState.relearning;
    if (repetitions <= 0) return MemoryState.newCard;
    if (intervalDays >= 14 || stabilityDays >= 14) return MemoryState.mature;
    if (intervalDays >= 2 || stabilityDays >= 2) return MemoryState.young;
    return MemoryState.learning;
  }

  double get successRate {
    final total = successes + failures;
    return total == 0 ? 0 : successes / total;
  }

  ReviewCard copyWith({
    int? repetitions,
    int? intervalDays,
    int? lapses,
    int? successes,
    int? failures,
    double? difficulty,
    double? stabilityDays,
    DateTime? dueAt,
    DateTime? lastReviewedAt,
  }) =>
      ReviewCard(
        itemId: itemId,
        facetType: facetType,
        variantKey: variantKey,
        repetitions: repetitions ?? this.repetitions,
        intervalDays: intervalDays ?? this.intervalDays,
        lapses: lapses ?? this.lapses,
        successes: successes ?? this.successes,
        failures: failures ?? this.failures,
        difficulty: difficulty ?? this.difficulty,
        stabilityDays: stabilityDays ?? this.stabilityDays,
        dueAt: dueAt ?? this.dueAt,
        lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'facetType': facetType.wireName,
        'variantKey': ReviewFacetKey.normalizeVariant(variantKey),
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'lapses': lapses,
        'successes': successes,
        'failures': failures,
        'difficulty': difficulty,
        'stabilityDays': stabilityDays,
        'dueAt': dueAt.toIso8601String(),
        'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      };

  factory ReviewCard.fromJson(Map<String, dynamic> j) {
    final id = (j['itemId'] ?? '').toString().trim();
    final now = DateTime.now();
    var due = DateTime.tryParse((j['dueAt'] ?? '').toString()) ?? now;
    var last = DateTime.tryParse((j['lastReviewedAt'] ?? '').toString());
    if (due.isBefore(DateTime(2000))) due = now;
    if (due.isAfter(now.add(const Duration(days: 3650))))
      due = now.add(const Duration(days: 3650));
    if (last != null && last.isAfter(now.add(const Duration(days: 1))))
      last = now;
    if (last != null && last.isBefore(DateTime(2000))) last = now;
    return ReviewCard(
      itemId: id,
      facetType: ReviewFacetType.fromWire(j['facetType']?.toString()),
      variantKey: ReviewFacetKey.normalizeVariant(j['variantKey']?.toString()),
      repetitions: _boundInt(_int(j['repetitions']), 0, 1000),
      intervalDays: _boundInt(_int(j['intervalDays']), 0, 3650),
      lapses: _boundInt(_int(j['lapses']), 0, 1000),
      successes: _boundInt(_int(j['successes']), 0, 10000),
      failures: _boundInt(_int(j['failures']), 0, 10000),
      difficulty: _boundDouble(_double(j['difficulty'], 1.3), .5, 2.5),
      stabilityDays: _boundDouble(_double(j['stabilityDays'], 0), 0, 3650),
      dueAt: due,
      lastReviewedAt: last,
    );
  }

  static int _int(Object? v) =>
      v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
  static double _double(Object? v, double fallback) {
    final parsed =
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
    return parsed == null || !parsed.isFinite ? fallback : parsed;
  }
  static int _boundInt(int v, int min, int max) =>
      v < min ? min : (v > max ? max : v);
  static double _boundDouble(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);
}

class LearnerState {
  final int xp, streak;
  final Set<String> learned, review, favoriteVerbs;
  final Map<String, ReviewCard> reviewCards;
  final List<Attempt> attempts;
  final List<AssessmentHistory> assessmentHistory;
  final List<PlacementDiagnosticRecord> placementHistory;
  final DateTime updatedAt;
  const LearnerState({
    this.xp = 0,
    this.streak = 0,
    this.learned = const {},
    this.review = const {},
    this.favoriteVerbs = const {},
    this.reviewCards = const {},
    this.attempts = const [],
    this.assessmentHistory = const [],
    this.placementHistory = const [],
    required this.updatedAt,
  });
  Iterable<ReviewCard> get meaningReviewCards sync* {
    for (final card in reviewCards.values) {
      if (card.facetKey.isLegacyMeaningKey) yield card;
    }
  }

  Iterable<Attempt> get meaningAttempts sync* {
    for (final attempt in attempts) {
      if (attempt.isMeaningFacet) yield attempt;
    }
  }

  ReviewCard? reviewCardForFacet(
    String conceptId, {
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
    String? variantKey,
  }) {
    final key = ReviewFacetKey(
      conceptId: conceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!key.isValid) return null;
    return reviewCards[key.storageKey];
  }

  Iterable<ReviewCard> reviewCardsForConcept(String conceptId) sync* {
    final normalized = conceptId.trim();
    if (normalized.isEmpty) return;
    for (final card in reviewCards.values) {
      if (card.itemId == normalized) yield card;
    }
  }

  LearnerState copyWith({
    int? xp,
    int? streak,
    Set<String>? learned,
    Set<String>? review,
    Set<String>? favoriteVerbs,
    Map<String, ReviewCard>? reviewCards,
    List<Attempt>? attempts,
    List<AssessmentHistory>? assessmentHistory,
    List<PlacementDiagnosticRecord>? placementHistory,
  }) =>
      LearnerState(
        xp: xp ?? this.xp,
        streak: streak ?? this.streak,
        learned: learned ?? this.learned,
        review: review ?? this.review,
        favoriteVerbs: favoriteVerbs ?? this.favoriteVerbs,
        reviewCards: reviewCards ?? this.reviewCards,
        attempts: attempts ?? this.attempts,
        assessmentHistory: assessmentHistory ?? this.assessmentHistory,
        placementHistory: placementHistory ?? this.placementHistory,
        updatedAt: DateTime.now(),
      );
}
