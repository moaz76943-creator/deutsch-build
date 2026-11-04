/// Task 1946: Sentence complexity evaluator grading syntax from A1 to C2
class SentenceComplexityClassifier {
  String gradeComplexity(int clauseCount, int tokenLength) => clauseCount > 2 ? 'B2' : 'A2';
}
