/// Task 1073: VSync backoff adapter during background/minimized app states
class VsyncBackoffAdapter {
  int vsyncDivisor = 1;
  void setMinimized(bool minimized) => vsyncDivisor = minimized ? 4 : 1;
}
