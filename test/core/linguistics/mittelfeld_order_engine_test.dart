import 'package:deutsch_build/core/linguistics/mittelfeld_order_engine.dart';

void main() {
  final engine = MittelfeldOrderEngine();

  // 1. صحيح: "Ich gebe es ihm" (Akk pronoun before Dat pronoun)
  final validPronouns = [
    const MittelfeldConstituent('es', ConstituentType.accusativePronoun),
    const MittelfeldConstituent('ihm', ConstituentType.dativePronoun),
  ];
  final resValid = engine.validate(validPronouns);
  assert(resValid.isValid, 'Failed on valid pronoun order: es ihm');

  // 2. خطأ نحوي قطعي: "*Ich gebe ihm es"
  final invalidPronouns = [
    const MittelfeldConstituent('ihm', ConstituentType.dativePronoun),
    const MittelfeldConstituent('es', ConstituentType.accusativePronoun),
  ];
  final resInvalid = engine.validate(invalidPronouns);
  assert(!resInvalid.isValid, 'Failed to catch invalid pronoun order: ihm es');

  // 3. صحيح في الأسماء: "dem Mann das Buch"
  final validNouns = [
    const MittelfeldConstituent('dem Mann', ConstituentType.dativeNoun),
    const MittelfeldConstituent('das Buch', ConstituentType.accusativeNoun),
  ];
  final resNouns = engine.validate(validNouns);
  assert(resNouns.isValid && resNouns.warnings.isEmpty);

  print('Mittelfeld engine unit verification passed.');
}
