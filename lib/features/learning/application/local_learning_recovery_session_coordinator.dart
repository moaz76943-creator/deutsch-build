import '../../session/universal_session_orchestrator.dart';
import '../data/local_learning_recovery_state_store.dart';
import '../domain/local_learning_recovery.dart';
import '../domain/local_learning_recovery_resume.dart';
import 'local_learning_recovery_controller.dart';

final class LocalLearningRecoverySessionCoordinator {
  LocalLearningRecoverySessionCoordinator({
    required LocalLearningRecoveryController controller,
    required LocalLearningRecoveryStateStore stateStore,
    LocalLearningRecoveryResumePlanner resumePlanner =
        const LocalLearningRecoveryResumePlanner(),
    DateTime Function()? clock,
  })  : _controller = controller,
        _stateStore = stateStore,
        _resumePlanner = resumePlanner,
        _clock = clock ?? DateTime.now;

  static const Duration newPromptCooldown = Duration(hours: 12);
  static const Duration resumePromptCooldown = Duration(minutes: 45);

  final LocalLearningRecoveryController _controller;
  final LocalLearningRecoveryStateStore _stateStore;
  final LocalLearningRecoveryResumePlanner _resumePlanner;
  final DateTime Function() _clock;

  Future<LocalLearningRecoverySession?> prepare(
    LocalLearningRecoveryPlan plan,
  ) async {
    final now = _clock().toUtc();
    final cursor = await _stateStore.loadCursor(plan.pairKey);
    final session = _resumePlanner.restore(
      plan: plan,
      cursor: cursor,
      now: now,
    );

    if (cursor != null && !session.resumed) {
      await _stateStore.clearCursor(plan.pairKey);
    }

    final lastPrompt = await _stateStore.loadLastPromptAt(plan.pairKey);
    if (lastPrompt != null) {
      if (now.isBefore(lastPrompt)) return null;
      final cooldown =
          session.resumed ? resumePromptCooldown : newPromptCooldown;
      if (now.difference(lastPrompt) < cooldown) return null;
    }
    return session;
  }

  Future<void> markPrompted(LocalLearningRecoverySession session) {
    return _stateStore.markPrompted(
      session.plan.pairKey,
      _clock().toUtc(),
    );
  }

  Future<void> begin(LocalLearningRecoverySession session) {
    return _stateStore.saveCursor(
      LocalLearningRecoveryResumeCursor(
        pairKey: session.plan.pairKey,
        createdAtUtc: _clock().toUtc(),
        remainingReviewKeys:
            session.plan.items.map((item) => item.reviewKey),
      ),
    );
  }

  Future<SessionStateSnapshot> record({
    required LocalLearningRecoverySession session,
    required int itemIndex,
    required bool correct,
    required Duration elapsed,
  }) async {
    final items = session.plan.items;
    if (itemIndex < 0 || itemIndex >= items.length) {
      throw RangeError.index(itemIndex, items, 'itemIndex');
    }
    final item = items[itemIndex];
    final snapshot = await _controller.record(
      recoveryItem: item,
      answer: correct
          ? 'local_learning_recovery:remembered'
          : 'local_learning_recovery:missed',
      correct: correct,
      seconds: elapsed.inSeconds.clamp(1, 3600).toInt(),
      hinted: false,
    );

    final cursor = await _stateStore.loadCursor(session.plan.pairKey);
    final remaining = cursor == null
        ? items
            .skip(itemIndex + 1)
            .map((candidate) => candidate.reviewKey)
            .toList(growable: false)
        : cursor.remainingReviewKeys
            .where((key) => key != item.reviewKey)
            .toList(growable: false);

    if (remaining.isEmpty) {
      await _stateStore.clearCursor(session.plan.pairKey);
    } else {
      await _stateStore.saveCursor(
        LocalLearningRecoveryResumeCursor(
          pairKey: session.plan.pairKey,
          createdAtUtc: cursor?.createdAtUtc ?? _clock().toUtc(),
          remainingReviewKeys: remaining,
        ),
      );
    }
    return snapshot;
  }
}
