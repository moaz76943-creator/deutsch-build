import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/exam_simulator/domain/exam_models.dart';
import 'package:deutsch_bilarabi/features/exam_simulator/domain/exam_scoring_engine.dart';

ExamDefinition _exam() => ExamDefinition(
      id: 'unit_exam',
      level: CefrExamLevel.a1,
      title: 'A1 Practice',
      duration: const Duration(minutes: 30),
      questions: const <ExamQuestion>[
        ExamQuestion(
          id: 'lesen_1',
          section: ExamSection.lesen,
          prompt: 'Wann fährt der Zug?',
          options: <String>['08:10', '08:40'],
          correctOptionIndex: 1,
          points: 30,
        ),
        ExamQuestion(
          id: 'hoeren_1',
          section: ExamSection.hoeren,
          prompt: 'Wo wartet die Person?',
          options: <String>['Büro', 'Bahnhof'],
          correctOptionIndex: 1,
          points: 30,
        ),
        ExamQuestion(
          id: 'schreiben_1',
          section: ExamSection.schreiben,
          prompt: 'Welche Nachricht passt?',
          options: <String>['Ich komme um neun.', 'Neun komme ich.'],
          correctOptionIndex: 0,
          points: 40,
        ),
      ],
    );

void main() {
  test('weighted score is normalized to 100 and 60 points passes', () {
    final report = ExamScoringEngine.score(
      exam: _exam(),
      answers: const <String, int>{
        'lesen_1': 1,
        'hoeren_1': 1,
        'schreiben_1': 1,
      },
    );

    expect(report.totalScore, 60);
    expect(report.passed, isTrue);
    expect(report.passThreshold, 60);
  });

  test('score below 60 does not pass', () {
    final report = ExamScoringEngine.score(
      exam: _exam(),
      answers: const <String, int>{
        'lesen_1': 1,
      },
    );

    expect(report.totalScore, 30);
    expect(report.passed, isFalse);
  });

  test('section breakdown reports earned possible and percentage', () {
    final report = ExamScoringEngine.score(
      exam: _exam(),
      answers: const <String, int>{
        'lesen_1': 1,
        'hoeren_1': 0,
        'schreiben_1': 0,
      },
    );

    final lesen = report.sections[ExamSection.lesen]!;
    final hoeren = report.sections[ExamSection.hoeren]!;
    expect(lesen.earnedPoints, 30);
    expect(lesen.possiblePoints, 30);
    expect(lesen.percentage, 100);
    expect(hoeren.earnedPoints, 0);
    expect(hoeren.percentage, 0);
  });

  test('unanswered and invalid option indexes receive no points', () {
    final report = ExamScoringEngine.score(
      exam: _exam(),
      answers: const <String, int>{
        'lesen_1': 99,
      },
    );

    expect(report.totalScore, 0);
    expect(report.passed, isFalse);
  });
}
