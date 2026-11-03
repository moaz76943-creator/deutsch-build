class MemoryPressureLevelInterceptor {
  int pressureLevel = 0; // 0: Normal, 1: Moderate, 2: Critical
  void updateLevel(int lvl) => pressureLevel = lvl;
}
