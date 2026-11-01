class AdaptiveFrameDropCompensator {
  int droppedFrames = 0;
  List<double> concealDrop(List<double> previousFrame) {
    droppedFrames++;
    return previousFrame.map((s) => s * 0.8).toList();
  }
}
