/// Task 1693: Order-independent depth peeling compositor for portal edges
class DepthPeelingCompositor {
  int getRequiredPasses(int transparentLayers) => transparentLayers.clamp(2, 4);
}
