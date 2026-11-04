class CefrA1WritingPart1FormFillingEngine {
  final Map<String, String> expectedFields = {'familyName': '', 'firstName': '', 'birthPlace': '', 'postalCode': ''};
  bool validateField(String field, String value) => value.trim().isNotEmpty;
}
