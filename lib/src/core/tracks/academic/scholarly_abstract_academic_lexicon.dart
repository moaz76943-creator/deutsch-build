class ScholarlyAbstractAcademicLexicon {
  final Map<String, String> components = {'hypothesis': 'فرضية البحث', 'methodology': 'المنهجية المتبعة', 'findings': 'أبرز النتائج'};
  String getTerm(String key) => components[key] ?? key;
}
