/// Task 1042: Bluetooth SCO / A2DP profile change & seamless codec fallback router
class BluetoothCodecFallbackRouter {
  String activeProfile = 'A2DP';
  void switchProfile(String newProfile) => activeProfile = newProfile;
  bool get isScoActive => activeProfile == 'SCO';
}
