import 'dart:async';

import 'package:deutsch_bilarabi/features/placement/application/placement_test_notifier.dart';
import 'package:deutsch_bilarabi/features/placement/domain/placement_models.dart';
import 'package:deutsch_bilarabi/features/placement/domain/placement_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'initial question fetch failure can retry without losing the selected goal',
    () async {
      final repository = _InitialFailureRepository();
      final notifier = PlacementTestNotifier(
        repository: repository,
        profileRepository: _RecordingProfileRepository(),
      );
      addTearDown(notifier.dispose);

      notifier.selectGoal(PlacementLearningGoal.travel);
      await notifier.start();

      expect(notifier.state.session, isNull);
      expect(notifier.state.learningGoal, PlacementLearningGoal.travel);
      expect(notifier.state.errorMessage, isNotNull);

      await notifier.retry();

      expect(notifier.state.currentQuestion?.id, 'initial-retry');
      expect(notifier.state.learningGoal, PlacementLearningGoal.travel);
      expect(notifier.state.errorMessage, isNull);
    },
  );

  test(
    'question fetch failure clears the consumed question and can recover without duplicate-answer crash',
    () async {
      final repository = _FlakyQuestionRepository();
      final notifier = PlacementTestNotifier(
        repository: repository,
        profileRepository: _RecordingProfileRepository(),
      );
      addTearDown(notifier.dispose);

      notifier.selectGoal(PlacementLearningGoal.studyExam);
      await notifier.start();

      expect(notifier.state.currentQuestion?.id, 'q-1');

      await notifier.submitOption('correct');

      expect(notifier.state.session?.answers, hasLength(1));
      expect(notifier.state.currentQuestion, isNull);
      expect(notifier.state.errorMessage, isNotNull);

      await notifier.retry();

      expect(notifier.state.session?.answers, hasLength(1));
      expect(notifier.state.currentQuestion?.id, 'q-2');
      expect(notifier.state.errorMessage, isNull);
    },
  );

  test(
    'failed result persistence blocks completion until retry persists the placement result',
    () async {
      final profile = _RecordingProfileRepository(failuresBeforeSuccess: 1);
      final notifier = PlacementTestNotifier(
        repository: _SequentialQuestionRepository(),
        profileRepository: profile,
      );
      addTearDown(notifier.dispose);

      notifier.selectGoal(PlacementLearningGoal.work);
      await notifier.start();

      for (var answer = 0; answer < 5; answer += 1) {
        await notifier.submitOption('correct');
      }

      expect(notifier.state.result, isNotNull);
      expect(notifier.state.resultPersisted, isFalse);
      expect(notifier.state.canStartLearning, isFalse);
      expect(notifier.state.errorMessage, isNotNull);
      expect(profile.applyCalls, 1);

      await notifier.retry();

      expect(notifier.state.resultPersisted, isTrue);
      expect(notifier.state.canStartLearning, isTrue);
      expect(notifier.state.errorMessage, isNull);
      expect(profile.applyCalls, 2);
      expect(profile.appliedAt, hasLength(2));
      expect(profile.appliedAt[1], profile.appliedAt[0]);
    },
  );

  test(
    'async completion after notifier disposal does not notify a disposed ChangeNotifier',
    () async {
      final repository = _DelayedQuestionRepository();
      final notifier = PlacementTestNotifier(
        repository: repository,
        profileRepository: _RecordingProfileRepository(),
      );

      notifier.selectGoal(PlacementLearningGoal.dailyLife);
      final startFuture = notifier.start();
      notifier.dispose();

      repository.completeFirstQuestion();

      await expectLater(startFuture, completes);
    },
  );
}

PlacementQuestion _question(String id, PlacementLevel level) =>
    PlacementQuestion(
      id: id,
      promptArabic: 'اختر الإجابة الصحيحة',
      level: level,
      pattern: PlacementQuestionPattern.multipleChoice,
      options: const <PlacementOption>[
        PlacementOption(id: 'correct', text: 'صحيح'),
        PlacementOption(id: 'wrong', text: 'خطأ'),
      ],
      correctOptionId: 'correct',
      skillTag: 'grammar',
    );

final class _InitialFailureRepository implements PlacementRepository {
  var calls = 0;

  @override
  Future<int> availableQuestionCount() async => 1;

  @override
  Future<PlacementQuestion?> nextQuestion({
    required PlacementLevel level,
    required Set<String> excludeIds,
  }) async {
    calls += 1;
    if (calls == 1) {
      throw StateError('simulated_initial_load_failure');
    }
    return _question('initial-retry', level);
  }
}

final class _FlakyQuestionRepository implements PlacementRepository {
  var calls = 0;

  @override
  Future<int> availableQuestionCount() async => 2;

  @override
  Future<PlacementQuestion?> nextQuestion({
    required PlacementLevel level,
    required Set<String> excludeIds,
  }) async {
    calls += 1;
    if (calls == 1) return _question('q-1', level);
    if (calls == 2) {
      throw StateError('simulated_question_load_failure');
    }
    return _question('q-2', level);
  }
}

final class _SequentialQuestionRepository implements PlacementRepository {
  var _counter = 0;

  @override
  Future<int> availableQuestionCount() async => 9;

  @override
  Future<PlacementQuestion?> nextQuestion({
    required PlacementLevel level,
    required Set<String> excludeIds,
  }) async {
    _counter += 1;
    return _question('seq-$_counter', level);
  }
}

final class _DelayedQuestionRepository implements PlacementRepository {
  final Completer<PlacementQuestion?> _firstQuestion =
      Completer<PlacementQuestion?>();

  @override
  Future<int> availableQuestionCount() async => 1;

  @override
  Future<PlacementQuestion?> nextQuestion({
    required PlacementLevel level,
    required Set<String> excludeIds,
  }) =>
      _firstQuestion.future;

  void completeFirstQuestion() {
    if (!_firstQuestion.isCompleted) {
      _firstQuestion.complete(_question('delayed-1', PlacementLevel.a2));
    }
  }
}

final class _RecordingProfileRepository implements PlacementProfileRepository {
  _RecordingProfileRepository({this.failuresBeforeSuccess = 0});

  final int failuresBeforeSuccess;
  final List<DateTime?> appliedAt = <DateTime?>[];
  var applyCalls = 0;

  @override
  Future<void> applyResult(PlacementResult result, {DateTime? at}) async {
    applyCalls += 1;
    appliedAt.add(at);
    if (applyCalls <= failuresBeforeSuccess) {
      throw StateError('simulated_profile_persistence_failure');
    }
  }
}
