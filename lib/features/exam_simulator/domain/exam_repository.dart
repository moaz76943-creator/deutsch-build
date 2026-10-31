import 'exam_models.dart';

abstract interface class ExamRepository {
  Future<ExamDefinition> loadExam(CefrExamLevel level);
}
