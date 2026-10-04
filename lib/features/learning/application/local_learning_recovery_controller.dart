import 'package:flutter/foundation.dart';

import '../../../core/content_contract.dart';
import '../../../services/repository.dart';
import '../../session/universal_session_orchestrator.dart';
import '../domain/local_learning_recovery.dart';

/// Application boundary for return-time local learning recovery.
///
/// Reads only the canonical pair-scoped progress authority and delegates every
/// answer write to [UniversalSessionOrchestrator]. No recovery-specific progress
/// store is created.
final class LocalLearningRecoveryController extends ChangeNotifier {
  LocalLearningRecoveryController({
    required LearnerRepository repository,
    required UniversalSessionOrchestrator sessionOrchestrator,
    required LearningRecoveryContentLookup contentLookup,
    LocalLearningRecoveryPlanner planner =
        const LocalLearningRecoveryPlanner(),
  })  : _repository = repository,
        _sessionOrchestrator = sessionOrchestrator,
        _contentLookup = contentLookup,
        _planner = planner;

  final LearnerRepository _repository;
  final UniversalSessionOrchestrator _sessionOrchestrator;
  final LearningRecoveryContentLookup _contentLookup;
  final LocalLearningRecoveryPlanner _planner;

  int _requestGeneration = 0;
  bool _checking = false;
  LocalLearningRecoveryPlan? _plan;

  bool get isChecking => _checking;
  LocalLearningRecoveryPlan? get plan => _plan;
  bool get hasRecovery => _plan != null;

  Future<LocalLearningRecoveryPlan?> refreshOnReturn({
    DateTime? now,
  }) async {
    final generation = ++_requestGeneration;
    _checking = true;
    notifyListeners();

    try {
      final snapshot = await _repository.loadPairProgress();
      final next = _planner.build(
        snapshot: snapshot,
        contentLookup: _contentLookup,
        now: now,
      );
      if (generation != _requestGeneration) return _plan;
      _plan = next;
      return _plan;
    } on Object {
      if (generation == _requestGeneration) {
        _plan = null;
      }
      return null;
    } finally {
      if (generation == _requestGeneration) {
        _checking = false;
        notifyListeners();
      }
    }
  }

  Future<SessionStateSnapshot> record({
    required LocalLearningRecoveryItem recoveryItem,
    required String answer,
    required bool correct,
    required int seconds,
    bool hinted = false,
  }) {
    return _sessionOrchestrator.record(
      SessionReviewInput<LearningContent>(
        item: recoveryItem.item,
        answer: answer,
        correct: correct,
        seconds: seconds.clamp(1, 3600).toInt(),
        hinted: hinted,
        facetType: recoveryItem.facetType,
        variantKey: recoveryItem.variantKey,
        skillOverride: recoveryItem.item.skill,
      ),
    );
  }

  void dismiss() {
    if (_plan == null) return;
    _plan = null;
    notifyListeners();
  }
}
