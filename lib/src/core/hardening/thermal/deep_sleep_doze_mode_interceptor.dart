/// Task 1067: Android Doze / iOS Low Power Mode state adapter
class DozeModeInterceptor {
  bool isDozeActive = false;
  void onDozeStateChange(bool active) => isDozeActive = active;
  bool get shouldSuspendNonCritical => isDozeActive;
}
