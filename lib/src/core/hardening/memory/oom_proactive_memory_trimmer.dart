class OomProactiveMemoryTrimmer {
  bool isTrimmingActive = false;
  void onTrimMemoryCritical() {
    isTrimmingActive = true;
  }
}
