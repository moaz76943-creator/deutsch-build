import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/exam_simulator/data/local_exam_repository.dart';
import 'package:deutsch_bilarabi/features/exam_simulator/domain/exam_models.dart';

void main() {
  test('A1 local practice exam covers all requested sections', () async {
    const repository = LocalExamRepository();

    final exam = await repository.loadExam(CefrExamLevel.a1);

    expect(exam.questions, isNotEmpty);
    expect(
      exam.questions.map((question) => question.section).toSet(),
      containsAll(<ExamSection>[
        ExamSection.lesen,
        ExamSection.hoeren,
        ExamSection.schreiben,
      ]),
    );
    expect(exam.totalPoints, 100);
  });

  test('A1 dataset uses original neutral everyday contexts', () async {
    const repository = LocalExamRepository();
    final exam = await repository.loadExam(CefrExamLevel.a1);
    final joined = exam.questions
        .expand((question) => <String>[
              question.prompt,
              question.stimulus ?? '',
              ...question.options,
            ])
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'partei',
      'wahl',
      'religion',
      'kirche',
      'moschee',
      'krieg',
      'waffe',
    ]) {
      expect(joined.contains(forbidden), isFalse, reason: forbidden);
    }
  });

  test('A2 repository entry is available for simulator expansion', () async {
    const repository = LocalExamRepository();

    final exam = await repository.loadExam(CefrExamLevel.a2);

    expect(exam.level, CefrExamLevel.a2);
    expect(exam.totalPoints, 100);
    expect(exam.questions.length, greaterThanOrEqualTo(6));
  });
}
