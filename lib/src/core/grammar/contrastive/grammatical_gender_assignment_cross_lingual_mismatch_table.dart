/// Task 1391: Cross-lingual gender mismatch mapper (Sonne/Mond/Soleil/Lune)
class GenderMismatchTable {
  String getGender(String word, String lang) => (word == 'sonne' && lang == 'de') ? 'Fem' : ((word == 'soleil' && lang == 'fr') ? 'Masc' : 'Fem');
}
