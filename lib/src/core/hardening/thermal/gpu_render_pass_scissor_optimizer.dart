/// Task 1076: GPU scissor test & overdraw elimination for low thermal dissipation
class GpuScissorOptimizer {
  bool scissorEnabled = true;
  void toggleScissor(bool enable) => scissorEnabled = enable;
}
