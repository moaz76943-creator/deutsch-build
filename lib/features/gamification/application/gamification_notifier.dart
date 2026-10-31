import 'dart:async';
import 'dart:math' as math;

import '../../../core/srs_facets.dart';
import '../domain/achievement_models.dart';
import '../domain/gamification_models.dart';
import '../gamification_repository.dart';

enum GamificationUiEventType {
  levelUp,
  badgeUnlocked,
  streakFreezeUsed,
}

final class GamificationUiEvent {
  const GamificationUiEvent({
    required this.type,
    this.badge,
    this.fromLevel,
    this.toLevel,
  });

  final GamificationUiEventType type;
  final AchievementBadge? badge;
  final int? fromLevel;
  final int? toLevel;
}

final class GamificationViewState {
  const GamificationViewState({
    required this.streak,
    required this.progress,
    required this.badges,
    required this.badgeProgress,
  });

  final UserStreak streak;
  final UserXpRecord progress;
  final List<AchievementBadge> badges;
  final Map<String, double> badgeProgress;

  factory GamificationViewState.fromSnapshot(GamificationSnapshot snapshot) {
    final progress = <String, double>{};
    for (final badge in snapshot.badges) {
      progress[badge.id] = _badgeProgress(badge, snapshot.profile);
    }
    return GamificationViewState(
      streak: snapshot.userStreak,
      progress: snapshot.userXpRecord,
      badges: snapshot.achievementBadges,
      badgeProgress: Map<String, double>.unmodifiable(progress),
    );
  }

  static double _badgeProgress(
    MilestoneBadge badge,
    GamificationProfile profile,
  ) {
    final ratios = <double>[];
    final xpThreshold = badge.xpThreshold;
    if (xpThreshold != null && xpThreshold > 0) {
      ratios.add((profile.totalXp / xpThreshold).clamp(0.0, 1.0).toDouble());
    }
    final streakThreshold = badge.streakThreshold;
    if (streakThreshold != null && streakThreshold > 0) {
      ratios.add(
        (profile.currentStreak / streakThreshold)
            .clamp(0.0, 1.0)
            .toDouble(),
      );
    }
    if (ratios.isEmpty) return 0;
    return ratios.reduce(math.min);
  }
}

final class GamificationUpdate {
  const GamificationUpdate({
    required this.state,
    required this.events,
  });

  final GamificationViewState state;
  final List<GamificationUiEvent> events;
}

final class GamificationNotifier {
  GamificationNotifier(this._repository);

  final GamificationRepository _repository;
  final StreamController<GamificationUiEvent> _events =
      StreamController<GamificationUiEvent>.broadcast();

  GamificationSnapshot? _snapshot;
  bool _disposed = false;

  Stream<GamificationUiEvent> get events => _events.stream;

  GamificationViewState? get state {
    final snapshot = _snapshot;
    return snapshot == null ? null : GamificationViewState.fromSnapshot(snapshot);
  }

  Future<GamificationViewState> initialize() async {
    _ensureActive();
    final snapshot = await _repository.loadSnapshot();
    _snapshot = snapshot;
    return GamificationViewState.fromSnapshot(snapshot);
  }

  Future<GamificationUpdate> completeExercise({
    required String activityId,
    required DateTime completedAtUtc,
    required int earnedXp,
    required int timezoneOffsetMinutes,
    bool useStreakFreeze = false,
  }) =>
      completeSession(
        sessionId: activityId,
        completedAtUtc: completedAtUtc,
        earnedXp: earnedXp,
        timezoneOffsetMinutes: timezoneOffsetMinutes,
        useStreakFreeze: useStreakFreeze,
        facetType: ReviewFacetType.meaningRecall,
      );

  Future<GamificationUpdate> completeCardReview({
    required String activityId,
    required DateTime completedAtUtc,
    required int earnedXp,
    required int timezoneOffsetMinutes,
    bool useStreakFreeze = false,
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
  }) =>
      completeSession(
        sessionId: activityId,
        completedAtUtc: completedAtUtc,
        earnedXp: earnedXp,
        timezoneOffsetMinutes: timezoneOffsetMinutes,
        useStreakFreeze: useStreakFreeze,
        facetType: facetType,
      );

  Future<GamificationUpdate> completeSession({
    required String sessionId,
    required DateTime completedAtUtc,
    required int earnedXp,
    required int timezoneOffsetMinutes,
    bool useStreakFreeze = false,
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
  }) async {
    _ensureActive();
    final before = _snapshot ?? await _repository.loadSnapshot();
    final beforeView = GamificationViewState.fromSnapshot(before);

    await _repository.recordReview(
      GamificationReviewEvent(
        reviewId: sessionId,
        facetType: facetType,
        correct: true,
        hinted: false,
        requestedXp: earnedXp,
        occurredAtUtc: completedAtUtc.toUtc(),
        timezoneOffsetMinutes: timezoneOffsetMinutes,
        useStreakFreeze: useStreakFreeze,
      ),
    );

    final after = await _repository.loadSnapshot();
    _snapshot = after;
    final afterView = GamificationViewState.fromSnapshot(after);
    final emitted = <GamificationUiEvent>[];

    if (afterView.progress.currentLevel > beforeView.progress.currentLevel) {
      emitted.add(
        GamificationUiEvent(
          type: GamificationUiEventType.levelUp,
          fromLevel: beforeView.progress.currentLevel,
          toLevel: afterView.progress.currentLevel,
        ),
      );
    }

    final beforeUnlocked = <String>{
      for (final badge in beforeView.badges)
        if (badge.isUnlocked) badge.id,
    };
    for (final badge in afterView.badges) {
      if (badge.isUnlocked && !beforeUnlocked.contains(badge.id)) {
        emitted.add(
          GamificationUiEvent(
            type: GamificationUiEventType.badgeUnlocked,
            badge: badge,
          ),
        );
      }
    }

    if (beforeView.streak.freezeAvailable &&
        !afterView.streak.freezeAvailable) {
      emitted.add(
        const GamificationUiEvent(
          type: GamificationUiEventType.streakFreezeUsed,
        ),
      );
    }

    for (final event in emitted) {
      if (!_events.isClosed) _events.add(event);
    }
    return GamificationUpdate(
      state: afterView,
      events: List<GamificationUiEvent>.unmodifiable(emitted),
    );
  }

  Future<void> clear() async {
    _ensureActive();
    await _repository.clearGamification();
    _snapshot = await _repository.loadSnapshot();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _repository.close();
    await _events.close();
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('GamificationNotifier is disposed');
    }
  }
}
