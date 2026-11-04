/// Task 1502: Bluetooth Low Energy (BLE) proximity mesh peer discoverer
class BleMeshBeaconAnnouncer {
  bool isPeerNearby(int rssi) => rssi > -75;
}
