class CefrA2GrammarCasePrepositionsValidator {
  final Set<String> a2Structures = {'الماضي التام المركب', 'حروف الجر المكانية المشتركة', 'أدوات الربط السببية'};
  bool isValid(String struct) => a2Structures.contains(struct);
}
