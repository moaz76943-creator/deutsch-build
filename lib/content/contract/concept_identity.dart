// Universal Concept Identity - Post-V1 Expansion
// Decouples concept ID from display languages to prevent O(N^2) data explosion

class ConceptIdentity {
  final String conceptId;
  final String category;
  final Map<String, String> properties;

  const ConceptIdentity({
    required this.conceptId,
    required this.category,
    this.properties = const {},
  });

  bool validateConcept() {
    return conceptId.isNotEmpty && category.isNotEmpty;
  }
}
