/// Task 2122: Educational vocabulary for describing symptoms (pure language terminology)
class SymptomDescriptionLexicon {
  final List<String> commonTerms = ['Kopfschmerzen', 'Halsschmerzen', 'Fieber', 'Husten'];
  bool isValidTerm(String term) => commonTerms.contains(term);
}
