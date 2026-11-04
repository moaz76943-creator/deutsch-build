/// Task 2002: BLE beacon advertiser and scanner facilitating device handshake without WiFi
class BleMeshBeacon {
  bool isAdvertising = false;
  void startBeacon(String deviceUuid) => isAdvertising = true;
}
