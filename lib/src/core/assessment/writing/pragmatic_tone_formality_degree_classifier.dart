/// Task 1453: Classifies tone formality (informal, business, academic)
enum FormalityDegree { casual, neutral, formal, academic }
class FormalityDegreeClassifier {
  FormalityDegree classifyTone(String text) => text.contains('Sehr geehrte') ? FormalityDegree.formal : FormalityDegree.casual;
}
