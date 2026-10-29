import 'package:deutsch_build/core/linguistics/linguistics_coordinator.dart';
import 'package:deutsch_build/core/linguistics/cefr_difficulty_calculator_engine.dart';

void main() {
  final coordinator = LinguisticsCoordinator();

  // فحص تحليل جملة نموذجية: "Das ist ein Wörterbuch für den Studenten."
  final report = coordinator.analyze('Das ist ein Wörterbuch für den Studenten.');

  // 1. التحقق من سلامة الميتاداتا ومستوى CEFR
  assert(report.originalText.isNotEmpty);
  assert(report.cefrMetrics.wordCount == 7);

  // 2. التحقق من فك الكلمة المركبة (Wörterbuch -> das)
  final foundWorterbuch = report.decomposedCompounds.any((c) => c.headPart == 'buch' && c.derivedArticle == 'das');
  assert(foundWorterbuch, 'Failed: Wörterbuch not decomposed correctly');

  // 3. التحقق من رصد N-Deklination (Student)
  final foundNDeclension = report.linguisticNotes.any((n) => n.contains('N-Deklination'));
  assert(foundNDeclension, 'Failed: N-Deklination noun not flagged');

  // 4. التحقق من وصول الواجهة لكافة المحركات الـ 19
  assert(coordinator.adjectives.getEnding(gender: GrammaticalGender.masculine, grammaticalCase: GrammaticalCase.nominative, article: ArticleCategory.definite) == 'e');
  assert(coordinator.konjunktivIi.conjugatePresent('sein', GrammaticalPerson.ich) == 'wäre');

  print('Master Linguistics Coordinator unit assertions passed.');
}
