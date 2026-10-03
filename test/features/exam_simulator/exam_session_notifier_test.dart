import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/exam_simulator/application/exam_session_notifier.dart';
import 'package:deutsch_bilarabi/features/exam_simulator/domain/exam_models.dart';
import 'package:deutsch_bilarabi/features/exam_simulator/domain/exam_repository.dart';

final class _FakeExamRepository implements ExamRepository {
  const _FakeExamRepository();

  @override
  Future<ExamDefinition> loadExam(CefrExamLevel level) async {
    return ExamDefinition(
      id: 'timed_exam',
      level: level,
      title: 'Timed practice',
      duration: const Duration(minutes: 1),
      questions: const <ExamQuestion>[
        ExamQuestion(
          id: 'q1',
          section: ExamSection.lesen,
          prompt: 'Frage 1',
          options: <String>['A', 'B'],
          correctOptionIndex: 0,
          points: 50,
        ),
        ExamQuestion(
          id: 'q2',
          section: ExamSection.hoeren,
          prompt: 'Frage 2',
          options: <String>['A', 'B'],
          correctOptionIndex: 1,
          points: 50,
        ),
      ],
    );
  }
}

void main() {
  test('records answer and navigates between questions while active', () async {
    final notifier = ExamSessionNotifier(const _FakeExamRepository());
    addTearDown(notifier.dispose);

    await notifier.start(
      level: CefrExamLevel.a1,
      startedAtUtc: DateTime.utc(2026, 10, 3, 18),
    );
    expect(notifier.answerCurrent(0), isTrue);
    expect(notifier.state.session.answers['q1'], 0);
    expect(notifier.goNext(), isTrue);
    expect(notifier.state.currentQuestion.id, 'q2');
  });

  test('synchronizing past deadline auto-submits and locks editing', () async {
    final notifier = ExamSessionNotifier(const _FakeExamRepository());
    addTearDown(notifier.dispose);

    await notifier.start(
      level: CefrExamLevel.a1,
      startedAtUtc: DateTime.utc(2026, 10, 3, 18),
    );
    notifier.answerCurrent(0);

    notifier.synchronize(DateTime.utc(2026, 10, 3, 18, 1, 1));

    expect(notifier.state.session.isFinished, isTrue);
    expect(notifier.state.session.timedOut, isTrue);
    expect(notifier.state.report, isNotNull);
    expect(notifier.answerCurrent(1), isFalse);
    expect(notifier.goNext(), isFalse);
  });

  test('manual submit generates score report and locks session', () async {
    final notifier = ExamSessionNotifier(const _FakeExamRepository());
    addTearDown(notifier.dispose);

    await notifier.start(
      level: CefrExamLevel.a1,
      startedAtUtc: DateTime.utc(2026, 10, 3, 18),
    );
    notifier.answerCurrent(0);
    notifier.goNext();
    notifier.answerCurrent(1);

    final report = notifier.submit(
      submittedAtUtc: DateTime.utc(2026, 10, 3, 18, 0, 40),
    );

    expect(report.totalScore, 100);
    expect(report.passed, isTrue);
    expect(notifier.state.session.isFinished, isTrue);
  });

  test('remaining seconds never drops below zero', () async {
    final notifier = ExamSessionNotifier(const _FakeExamRepository());
    addTearDown(notifier.dispose);

    await notifier.start(
      level: CefrExamLevel.a1,
      startedAtUtc: DateTime.utc(2026, 10, 3, 18),
    );
    notifier.synchronize(DateTime.utc(2026, 10, 3, 19));

    expect(notifier.state.remainingSeconds, 0);
  });
}
