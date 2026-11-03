/// Task 1173: Pragmatic appropriateness evaluator (politeness markers)
class CulturalPragmaticsEvaluator {
  bool hasPolitenessMarker(String text) => text.contains('bitte') || text.contains('könnten Sie') || text.contains('من فضلك');
}
