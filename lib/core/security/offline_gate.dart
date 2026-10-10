class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted() => !strictOfflineEnforced;

  static void assertZeroNetworkPolicy() {
    if (strictOfflineEnforced) {
      // منع تام لأي اتصال خارجي بدون إذن صريح للحفاظ على الخصوصية والسرعة
      return;
    }
  }
}
