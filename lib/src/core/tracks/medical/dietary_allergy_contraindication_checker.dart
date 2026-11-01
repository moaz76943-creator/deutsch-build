class DietaryAllergyContraindicationChecker {
  final Set<String> knownAllergies = {};
  bool isSafe(String medicationIngredient) => !knownAllergies.contains(medicationIngredient.toLowerCase());
}
