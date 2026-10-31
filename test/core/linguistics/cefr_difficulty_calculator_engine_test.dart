import 'package:deutsch_build/core/linguistics/cefr_difficulty_calculator_engine.dart';

void main() {
  final engine = CefrDifficultyCalculatorEngine();

  // 1. جملة بسيطة جداً A1: "Das ist ein Buch."
  final resA1 = engine.analyze('Das ist ein Buch.');
  assert(resA1.estimatedLevel == CefrLevel.A1);
  assert(resA1.readabilityScore < 30.0);

  // 2. جملة مع رابط ومؤشر شرط B1: "Ich lerne Deutsch, obwohl es schwierig ist."
  final resB1 = engine.analyze('Ich lerne Deutsch, obwohl es schwierig ist.');
  assert(resB1.estimatedLevel == CefrLevel.B1);
  assert(resB1.advancedSyntacticMarkers.contains('obwohl'));

  // 3. جملة أكاديمية معقدة B2/C1 مع صلات إضافة وكلمات مركبة:
  final resB2C1 = engine.analyze('Der wissenschaftliche Artikel, dessen Ergebnisse berücksichtigt werden, ist infolgedessen relevant.');
  assert(resB2C1.estimatedLevel == CefrLevel.B2 || resB2C1.estimatedLevel == CefrLevel.C1);
  assert(resB2C1.advancedSyntacticMarkers.contains('dessen'));

  print('CEFR difficulty calculator unit assertions passed.');
}
