import 'content.dart';

enum AssessmentQuestionType {
  recall,
  grammar,
  translation,
  listening,
  production,
}

class AssessmentQuestion {
  final String id, itemId, prompt, expected;
  final AssessmentQuestionType type;
  final List<String> accepted;
  final String skill;
  const AssessmentQuestion({
    required this.id,
    required this.itemId,
    required this.prompt,
    required this.expected,
    required this.type,
    required this.accepted,
    required this.skill,
  });
}

class AssessmentResponse {
  final String questionId, itemId, answer;
  final bool correct, hinted;
  const AssessmentResponse({
    required this.questionId,
    required this.itemId,
    this.answer = '',
    required this.correct,
    required this.hinted,
  });
}

class AssessmentResult {
  final String id;
  final DateTime at;
  final int answered, correct, cleanCorrect;
  final double score;
  final Map<String, double> skillScores;
  final List<String> weakSkills, nextReviewItemIds;
  const AssessmentResult({
    required this.id,
    required this.at,
    required this.answered,
    required this.correct,
    required this.cleanCorrect,
    required this.score,
    required this.skillScores,
    required this.weakSkills,
    required this.nextReviewItemIds,
  });
}

String assessmentNormalize(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[.!?]+$'), '')
    .replaceAll(RegExp(r'\s+'), ' ');
bool assessmentAnswerMatches(
  AssessmentResponse response,
  AssessmentQuestion q,
) {
  if (!response.correct) return false;
  final a = assessmentNormalize(response.answer);
  if (a.isEmpty) return true;
  return {
    assessmentNormalize(q.expected),
    ...q.accepted.map(assessmentNormalize),
  }.contains(a);
}

ContentItem? assessmentFindItem(List<ContentItem> items, String id) {
  for (final x in items) {
    if (x.id == id) return x;
  }
  return null;
}
