/// Task 2124: Health insurance administrative terms (Krankenkassenkarte, Überweisungsschein)
class HealthInsuranceLexicon {
  bool isInsuranceTerm(String term) => ['Versichertenkarte', 'Zuzahlungsbefreiung', 'Rezeptgebühr'].contains(term);
}
