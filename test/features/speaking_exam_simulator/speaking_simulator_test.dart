import 'package:deutsch_bilarabi/features/speaking_exam_simulator/application/speaking_exam_notifier.dart';
import 'package:deutsch_bilarabi/features/speaking_exam_simulator/data/local_speaking_exam_repository.dart';
import 'package:deutsch_bilarabi/features/speaking_exam_simulator/domain/speaking_exam_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSpeakingExamRepository', () {
    test('filters Goethe and Telc B1-B2 speaking scenarios', () async {
      final repository = LocalSpeakingExamRepository();

      final goetheB1 = await repository.getScenarios(
        provider: ExamProvider.goethe,
        level: ExamLevel.b1,
      );
      final telcB2 = await repository.getScenarios(
        provider: ExamProvider.telc,
        level: ExamLevel.b2,
      );

      expect(goetheB1, isNotEmpty);
      expect(
        goetheB1.every(
          (item) =>
              item.provider == ExamProvider.goethe &&
              item.level == ExamLevel.b1,
        ),
        isTrue,
      );
      expect(telcB2, isNotEmpty);
      expect(
        telcB2.every(
          (item) =>
              item.provider == ExamProvider.telc &&
              item.level == ExamLevel.b2,
        ),
        isTrue,
      );
    });

    test('each scenario contains timed phases and debate material', () async {
      final repository = LocalSpeakingExamRepository();
      final scenarios = await repository.getScenarios();

      expect(scenarios, isNotEmpty);
      for (final scenario in scenarios) {
        expect(scenario.phases, isNotEmpty);
        expect(
          scenario.phases.every(
            (phase) => phase.duration.inSeconds > 0,
          ),
          isTrue,
        );
        expect(scenario.debateStatementDe, isNotEmpty);
        expect(scenario.debateStatementAr, isNotEmpty);
        expect(scenario.proArgumentsDe, isNotEmpty);
        expect(scenario.contraArgumentsDe, isNotEmpty);
        expect(scenario.partnerQuestionsDe, isNotEmpty);
      }
    });
  });

  group('SpeakingExamNotifier', () {
    test('loads filtered scenarios and initializes the first phase timer', () async {
      final notifier = SpeakingExamNotifier(LocalSpeakingExamRepository());
      addTearDown(notifier.dispose);

      await notifier.load(
        provider: ExamProvider.goethe,
        level: ExamLevel.b1,
      );

      expect(notifier.currentScenario, isNotNull);
      expect(notifier.currentPhaseIndex, 0);
      expect(
        notifier.secondsRemaining,
        notifier.currentPhase!.duration.inSeconds,
      );
      expect(notifier.isRunning, isFalse);
      expect(notifier.isCompleted, isFalse);
    });

    test('advanceClock decrements countdown and advances phases at zero', () async {
      final notifier = SpeakingExamNotifier(LocalSpeakingExamRepository());
      addTearDown(notifier.dispose);

      await notifier.load(
        provider: ExamProvider.telc,
        level: ExamLevel.b2,
      );

      final firstPhase = notifier.currentPhase!;
      notifier.advanceClock(
        Duration(seconds: firstPhase.duration.inSeconds - 1),
      );
      expect(notifier.secondsRemaining, 1);
      expect(notifier.currentPhaseIndex, 0);

      notifier.advanceClock(const Duration(seconds: 1));

      expect(notifier.currentPhaseIndex, 1);
      expect(
        notifier.secondsRemaining,
        notifier.currentPhase!.duration.inSeconds,
      );
    });

    test('manual nextPhase resets countdown and final phase completes exam', () async {
      final notifier = SpeakingExamNotifier(LocalSpeakingExamRepository());
      addTearDown(notifier.dispose);

      await notifier.load(
        provider: ExamProvider.goethe,
        level: ExamLevel.b2,
      );

      while (notifier.currentPhaseIndex <
          notifier.currentScenario!.phases.length - 1) {
        notifier.nextPhase();
      }

      expect(notifier.isCompleted, isFalse);
      notifier.nextPhase();

      expect(notifier.isCompleted, isTrue);
      expect(notifier.isRunning, isFalse);
      expect(notifier.secondsRemaining, 0);
    });

    test('selectStance and nextScenario reset speaking state', () async {
      final notifier = SpeakingExamNotifier(LocalSpeakingExamRepository());
      addTearDown(notifier.dispose);

      await notifier.load();

      final firstId = notifier.currentScenario!.id;
      notifier.selectStance(DebateStance.pro);
      notifier.advanceClock(const Duration(seconds: 10));

      expect(notifier.selectedStance, DebateStance.pro);

      notifier.nextScenario();

      expect(notifier.currentScenario, isNotNull);
      expect(notifier.currentScenario!.id, isNot(firstId));
      expect(notifier.currentPhaseIndex, 0);
      expect(notifier.selectedStance, isNull);
      expect(
        notifier.secondsRemaining,
        notifier.currentPhase!.duration.inSeconds,
      );
    });
  });
}
