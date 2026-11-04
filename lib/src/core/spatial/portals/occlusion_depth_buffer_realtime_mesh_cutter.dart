/// Task 1685: Real-time depth occlusion cutter for virtual flashcards
class OcclusionDepthCutter {
  bool isOccluded(double virtualDepth, double realDepth) => virtualDepth > realDepth;
}
