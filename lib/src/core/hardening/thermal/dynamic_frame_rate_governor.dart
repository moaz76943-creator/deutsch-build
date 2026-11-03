/// Task 1062: Adaptive 120Hz/60Hz/30Hz frame rate governor
class DynamicFpsGovernor {
  int targetFps = 60;
  void adaptToThermal(bool isHot, bool isBatterySaver) {
    targetFps = isHot ? 30 : (isBatterySaver ? 45 : 60);
  }
}
