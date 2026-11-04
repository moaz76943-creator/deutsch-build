/// Task 2104: Everyday banking terms (Girokonto, Überweisung) strictly excluding usurious interest
class HalalBankingLexicon {
  bool isHalalTerm(String term) => ['Kontoauszug', 'Überweisungsträger', 'Dauerauftrag'].contains(term);
}
