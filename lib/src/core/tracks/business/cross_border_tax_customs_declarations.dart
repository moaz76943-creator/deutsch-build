class CrossBorderTaxCustomsDeclarations {
  final Map<String, String> terms = {'tariff_code': 'رمز التعريفة الجمركية', 'duty_free': 'معفى من الرسوم'};
  String getTerm(String key) => terms[key] ?? key;
}
