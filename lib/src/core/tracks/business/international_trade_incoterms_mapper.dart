class InternationalTradeIncotermsMapper {
  final Map<String, String> incoterms = {'fob': 'تسليم على ظهر السفينة (FOB)', 'cif': 'شامل التكلفة والتأمين والشحن (CIF)'};
  String explainIncoterm(String code) => incoterms[code.toLowerCase()] ?? code;
}
