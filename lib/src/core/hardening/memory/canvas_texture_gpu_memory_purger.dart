/// Task 1013: Low-overhead GPU texture cache eviction controller
class CanvasTextureGpuPurger {
  int _evictionCount = 0;
  int purgeStaleTextures() {
    _evictionCount++;
    return _evictionCount;
  }
  int get totalPurges => _evictionCount;
}
