/// Task 1356: Checks Pronominaladverbien formation (da(r)+Preposition)
class PronominalAdverbChecker {
  String buildCompound(String prep) => 'aeiouäöü'.contains(prep[0].toLowerCase()) ? 'dar$prep' : 'da$prep';
}
