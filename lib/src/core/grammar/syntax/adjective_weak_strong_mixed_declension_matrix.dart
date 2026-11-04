/// Task 1308: German adjective endings (weak, strong, mixed)
class AdjectiveDeclensionMatrix {
  String getEnding(String declensionType, String grammaticalCase) => declensionType == 'weak' && grammaticalCase == 'Nom' ? 'e' : 'en';
}
