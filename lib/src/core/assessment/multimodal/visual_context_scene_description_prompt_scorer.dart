/// Task 1481: Picture-cued speaking assessment scorer for scene descriptions
class SceneDescriptionScorer {
  double scoreDescription(List<String> detectedKeywords, List<String> sceneTargets) {
    if (sceneTargets.isEmpty) return 100.0;
    int hits = detectedKeywords.where((k) => sceneTargets.contains(k)).length;
    return (hits / sceneTargets.length) * 100.0;
  }
}
