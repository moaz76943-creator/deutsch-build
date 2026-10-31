import 'package:deutsch_build/core/exercises/multiple_choice_generator.dart';

void main() {
  final generator = MultipleChoiceExerciseGenerator();

  // 1. فحص توليد سؤال لمفردة مع مشتتات من نفس الفئة (فواكه)
  final question = generator.generate(
    lemma: 'Apfel',
    correctMeaning: 'تفاحة',
    pos: 'noun',
    cefrLevel: 'A1',
    candidateDistractors: ['موزة', 'برتقالة', 'إجاصة', 'عنب'],
    deterministicSeed: 42,
  );

  // التحقق من المعايير البيداغوجية
  assert(question.options.length == 4, 'Failed: Must have exactly 4 options');
  assert(question.options.contains('تفاحة'), 'Failed: Correct meaning missing from options');
  assert(question.options[question.correctIndex] == 'تفاحة', 'Failed: Correct index points to wrong option');
  assert(question.prompt.contains('Apfel'));

  // التحقق من استبعاد المعنى الصحيح من المشتتات
  final filteredQuestion = generator.generate(
    lemma: 'Buch',
    correctMeaning: 'كتاب',
    pos: 'noun',
    cefrLevel: 'A1',
    candidateDistractors: ['كتاب', 'دفتر', 'قلم', 'جريدة'], // يحتوي على الإجابة الصحيحة
    deterministicSeed: 99,
  );
  assert(filteredQuestion.options.where((o) => o == 'كتاب').length == 1, 'Duplicate correct meaning found');

  print('Multiple choice generator unit assertions passed.');
}
