import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/content_contract.dart';
import '../../core/srs_facets.dart';
import '../../services/repository.dart';

final class SessionStateSnapshot {
  const SessionStateSnapshot({
    this.answered = 0,
    this.correct = 0,
    this.combo = 0,
    this.bestCombo = 0,
    this.sessionXp = 0,
    this.lastCorrect,
    this.lastFacet,
  });

  final int answered;
  final int correct;
  final int combo;
  final int bestCombo;
  final int sessionXp;
  final bool? lastCorrect;
  final ReviewFacetType? lastFacet;

  double get accuracy =>
      answered == 0 ? 0 : (correct / answered).clamp(0.0, 1.0).toDouble();

  SessionStateSnapshot copyWith({
    int? answered,
    int? correct,
    int? combo,
    int? bestCombo,
    int? sessionXp,
    bool? lastCorrect,
    ReviewFacetType? lastFacet,
  }) {
    return SessionStateSnapshot(
      answered: answered ?? this.answered,
      correct: correct ?? this.correct,
      combo: combo ?? this.combo,
      bestCombo: bestCombo ?? this.bestCombo,
      sessionXp: sessionXp ?? this.sessionXp,
      lastCorrect: lastCorrect,
      lastFacet: lastFacet,
    );
  }
}

final class SessionReviewInput<T extends LearningContent> {
  const SessionReviewInput({
    required this.item,
    required this.answer,
    required this.correct,
    required this.seconds,
    this.hinted = false,
    this.facetType = ReviewFacetType.meaningRecall,
    this.variantKey,
    this.skillOverride,
  });

  final T item;
  final String answer;
  final bool correct;
  final int seconds;
  final bool hinted;
  final ReviewFacetType facetType;
  final String? variantKey;
  final String? skillOverride;
}

abstract interface class SessionHapticDriver {
  Future<void> onCorrect({required int combo});
  Future<void> onIncorrect();
}

final class FlutterSessionHapticDriver implements SessionHapticDriver {
  const FlutterSessionHapticDriver();

  @override
  Future<void> onCorrect({required int combo}) {
    if (combo >= 5) return HapticFeedback.heavyImpact();
    if (combo >= 3) return HapticFeedback.mediumImpact();
    if (combo >= 2) return HapticFeedback.lightImpact();
    return HapticFeedback.selectionClick();
  }

  @override
  Future<void> onIncorrect() => HapticFeedback.selectionClick();
}

final class UniversalSessionOrchestrator extends ChangeNotifier {
  UniversalSessionOrchestrator({
    required LearnerRepository repository,
    SessionHapticDriver haptics = const FlutterSessionHapticDriver(),
  })  : _repository = repository,
        _haptics = haptics;

  final LearnerRepository _repository;
  final SessionHapticDriver _haptics;

  SessionStateSnapshot _state = const SessionStateSnapshot();
  Future<void> _queue = Future<void>.value();

  SessionStateSnapshot get state => _state;

  Future<SessionStateSnapshot> record<T extends LearningContent>(
    SessionReviewInput<T> input,
  ) {
    final completer = Completer<SessionStateSnapshot>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await _recordNow(input));
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<SessionStateSnapshot> _recordNow<T extends LearningContent>(
    SessionReviewInput<T> input,
  ) async {
    final beforeXp = _repository.load().xp;

    if (input.facetType == ReviewFacetType.meaningRecall &&
        ReviewFacetKey.normalizeVariant(input.variantKey) == null) {
      await _repository.record(
        item: input.item,
        answer: input.answer,
        correct: input.correct,
        seconds: input.seconds,
        hinted: input.hinted,
        skillOverride: input.skillOverride,
      );
    } else {
      await _repository.recordFacet(
        item: input.item,
        facetType: input.facetType,
        variantKey: input.variantKey,
        answer: input.answer,
        correct: input.correct,
        seconds: input.seconds,
        hinted: input.hinted,
      );
    }

    final after = await _repository.reloadPersisted();
    final awardedXp =
        (after.xp - beforeXp).clamp(0, LearnerRepository.maxXp).toInt();
    final combo = input.correct ? _state.combo + 1 : 0;
    final correctCount = _state.correct + (input.correct ? 1 : 0);

    _state = _state.copyWith(
      answered: _state.answered + 1,
      correct: correctCount,
      combo: combo,
      bestCombo: combo > _state.bestCombo ? combo : _state.bestCombo,
      sessionXp: (_state.sessionXp + awardedXp)
          .clamp(0, LearnerRepository.maxXp)
          .toInt(),
      lastCorrect: input.correct,
      lastFacet: input.facetType,
    );

    if (input.correct) {
      await _haptics.onCorrect(combo: combo);
    } else {
      await _haptics.onIncorrect();
    }

    notifyListeners();
    return _state;
  }

  void resetSession() {
    _state = const SessionStateSnapshot();
    notifyListeners();
  }
}
