/// Task 1372: Apposition and parenthetical clause linker (appos, parataxis)
class AppositionLinker {
  String getAppositiveRelation(bool isParenthetical) => isParenthetical ? 'parataxis' : 'appos';
}
