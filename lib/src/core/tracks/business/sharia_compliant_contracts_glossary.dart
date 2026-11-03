class ShariaCompliantContractsGlossary {
  final Map<String, String> contracts = {
    'murabaha': 'مرابحة (بيع برأس المال وربح معلوم)',
    'mudaraba': 'مضاربة (مشاركة بين المال والعمل)',
    'ijarah': 'إجارة (عقد منفعة بأجر معلوم)',
  };
  String getDefinition(String key) => contracts[key] ?? key;
}
