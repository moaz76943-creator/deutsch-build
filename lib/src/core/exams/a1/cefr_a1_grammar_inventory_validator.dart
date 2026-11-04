class CefrA1GrammarInventoryValidator {
  final Set<String> allowedTenses = {'المضارع البسيط', 'الأمر البسيط'};
  bool isAllowed(String tense) => allowedTenses.contains(tense);
}
