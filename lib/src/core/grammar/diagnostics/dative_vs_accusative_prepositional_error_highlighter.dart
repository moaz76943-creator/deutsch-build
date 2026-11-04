/// Task 1343: Erroneous case assignment after prepositions ('mit mich' -> 'mit mir')
class PrepositionalCaseErrorHighlighter {
  String correctPrepositionalError(String prep, String pronoun) => (prep == 'mit' && pronoun == 'mich') ? 'mir' : pronoun;
}
