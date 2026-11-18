import 'package:flutter/foundation.dart';

import '../../../core/content_contract.dart';
import '../../../models/learner.dart';
import '../domain/daily_drill_models.dart';
import '../domain/daily_drill_repository.dart';

final class DailyDrillState {
  const DailyDrillState({
    this.status = DailyDrillStatus.idle,
    this.session,
    this.currentIndex = 0,
    this.revealed = false,
    this.correctCount = 0,
    this.totalSeconds = 0,
    this.currentStreak = 0,
    this.sessionXp = 0,
    this.busy = false,
    this.summary,
  });

  final DailyDrillStatus status;
  final DailyDrillSession? session;
  final int currentIndex;
  final bool revealed;
  final int correctCount;
  final int totalSeconds;
  final int currentStreak;
  final int sessionXp;
  final bool busy;
  final DrillResultSummary? summary;

  FlashcardReviewItem? get currentItem {
    final activeSession = session;
    if (status != DailyDrillStatus.active ||
        activeSession == null ||
        currentIndex < 0 ||
        currentIndex >= activeSession.items.length) {
      return null;
    }
    return activeSession.items[currentIndex];
  }

  int get reviewedCount {
    if (status == DailyDrillStatus.completed) {
      return summary?.reviewedCards ?? 0;
    }
    return currentIndex;
  }

  double get liveAccuracy {
    final reviewed = reviewedCount;
    return reviewed == 0 ? 0 : correctCount / reviewed;
  }

  DailyDrillState copyWith({
    DailyDrillStatus? status,
    DailyDrillSession? session,
    int? currentIndex,
    bool? revealed,
    int? correctCount,
    int? totalSeconds,
    int? currentStreak,
    int? sessionXp,
    bool? busy,
    DrillResultSummary? summary,
    bool clearSummary = false,
  }) {
    return DailyDrillState(
      status: status ?? this.status,
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      revealed: revealed ?? this.revealed,
      correctCount: correctCount ?? this.correctCount,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      currentStreak: currentStreak ?? this.currentStreak,
      sessionXp: sessionXp ?? this.sessionXp,
      busy: busy ?? this.busy,
      summary: clearSummary ? null : summary ?? this.summary,
    );
  }
}

final class DailyDrillController extends ChangeNotifier {
  DailyDrillController({
    required DailyDrillRepository repository,
    required DailyDrillReviewSink reviewSink,
  })  : _repository = repository,
        _reviewSink = reviewSink;

  final DailyDrillRepository _repository;
  final DailyDrillReviewSink _reviewSink;

  DailyDrillState _state = const DailyDrillState();

  DailyDrillState get state => _state;

  void start({
    required LearnerState learnerState,
    required Iterable<LearningContent> corpus,
    required DateTime now,
    int limit = 10,
  }) {
    final target = limit.clamp(1, 20).toInt();
    final items = _repository.dueReviews(
      state: learnerState,
      corpus: corpus,
      now: now,
      limit: target,
    );
    final session = DailyDrillSession(
      id: 'daily-${now.toUtc().microsecondsSinceEpoch}',
      startedAt: now,
      items: items,
      targetCount: target,
    );

    if (session.isEmpty) {
      _state = DailyDrillState(
        status: DailyDrillStatus.completed,
        session: session,
        currentStreak: 0,
        summary: DrillResultSummary(
          reviewedCards: 0,
          correctCards: 0,
          totalSeconds: 0,
          currentStreak: 0,
          sessionXp: 0,
        ),
      );
    } else {
      _state = DailyDrillState(
        status: DailyDrillStatus.active,
        session: session,
        currentStreak: 0,
      );
    }
    notifyListeners();
  }

  void reveal() {
    if (_state.status != DailyDrillStatus.active ||
        _state.busy ||
        _state.currentItem == null) {
      return;
    }
    if (_state.revealed) return;
    _state = _state.copyWith(revealed: true);
    notifyListeners();
  }

  Future<void> gradeCurrent({
    required bool correct,
    required Duration elapsed,
  }) async {
    if (_state.status != DailyDrillStatus.active ||
        _state.currentItem == null) {
      throw StateError('No active daily drill card.');
    }
    if (!_state.revealed) {
      throw StateError('Reveal the card before grading recall.');
    }
    if (_state.busy) {
      throw StateError('A daily drill review is already being recorded.');
    }

    final current = _state.currentItem!;
    final seconds = elapsed.inSeconds.clamp(1, 3600).toInt();
    _state = _state.copyWith(busy: true);
    notifyListeners();

    try {
      final receipt = await _reviewSink.record(
        item: current.item,
        correct: correct,
        seconds: seconds,
      );
      final nextCorrect = _state.correctCount + (correct ? 1 : 0);
      final nextSeconds = _state.totalSeconds + seconds;
      final activeSession = _state.session!;
      final reviewed = _state.currentIndex + 1;
      final complete = reviewed >= activeSession.items.length;

      if (complete) {
        final summary = DrillResultSummary(
          reviewedCards: reviewed,
          correctCards: nextCorrect,
          totalSeconds: nextSeconds,
          currentStreak: receipt.currentStreak,
          sessionXp: receipt.sessionXp,
        );
        _state = _state.copyWith(
          status: DailyDrillStatus.completed,
          correctCount: nextCorrect,
          totalSeconds: nextSeconds,
          currentStreak: receipt.currentStreak,
          sessionXp: receipt.sessionXp,
          busy: false,
          summary: summary,
        );
      } else {
        _state = _state.copyWith(
          currentIndex: _state.currentIndex + 1,
          revealed: false,
          correctCount: nextCorrect,
          totalSeconds: nextSeconds,
          currentStreak: receipt.currentStreak,
          sessionXp: receipt.sessionXp,
          busy: false,
          clearSummary: true,
        );
      }
      notifyListeners();
    } on Object {
      _state = _state.copyWith(busy: false);
      notifyListeners();
      rethrow;
    }
  }
}
