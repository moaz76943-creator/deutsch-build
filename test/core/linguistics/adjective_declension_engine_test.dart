import 'package:deutsch_build/core/linguistics/adjective_declension_engine.dart';

void main() {
  final engine = AdjectiveDeclensionEngine();

  // 1. Weak: der kalte Kaffee (Nom Maskulin Definite -> -e)
  assert(engine.inflect('kalt',
      gender: GrammaticalGender.masculine,
      grammaticalCase: GrammaticalCase.nominative,
      article: ArticleCategory.definite) == 'kalte');

  // 2. Mixed: ein kalter Kaffee (Nom Maskulin Indefinite -> -er)
  assert(engine.inflect('kalt',
      gender: GrammaticalGender.masculine,
      grammaticalCase: GrammaticalCase.nominative,
      article: ArticleCategory.indefinite) == 'kalter');

  // 3. Mixed: einen kalten Kaffee (Akk Maskulin Indefinite -> -en)
  assert(engine.inflect('kalt',
      gender: GrammaticalGender.masculine,
      grammaticalCase: GrammaticalCase.accusative,
      article: ArticleCategory.indefinite) == 'kalten');

  // 4. Strong: mit frischem Brot (Dat Neutral None -> -em)
  assert(engine.inflect('frisch',
      gender: GrammaticalGender.neutral,
      grammaticalCase: GrammaticalCase.dative,
      article: ArticleCategory.none) == 'frischem');

  print('Adjektivdeklination engine assertions passed.');
}
