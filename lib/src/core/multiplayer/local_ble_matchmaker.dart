import 'dart:async';

/// Peer learner discovered nearby via Bluetooth LE advertising.
class DiscoveredPeer {
  final String peerId;
  final String displayName;
  final String activeLanguagePair; // e.g. "ar_de"
  final int rssiSignalStrength;     // e.g. -55 dBm
  final DateTime discoveredAt;

  const DiscoveredPeer({
    required this.peerId,
    required this.displayName,
    required this.activeLanguagePair,
    required this.rssiSignalStrength,
    required this.discoveredAt,
  });
}

/// Platform bridge contract for native Bluetooth LE scanning and advertising.
abstract class BlePlatformBridge {
  Future<bool> startAdvertising({required String localName, required String serviceUuid});
  Future<void> stopAdvertising();
  Future<bool> startScanning({required String serviceUuid});
  Future<void> stopScanning();
}

/// Discovers nearby learners within 10 meters via BLE for peer-to-peer vocabulary duels.
class LocalBleMatchmaker {
  static const String polyglotServiceUuid = '0000feaa-0000-1000-8000-00805f9b34fb';

  final BlePlatformBridge bridge;
  final Map<String, DiscoveredPeer> _discoveredPeers = {};
  bool _isAdvertising = false;
  bool _isScanning = false;

  LocalBleMatchmaker({required this.bridge});

  bool get isAdvertising => _isAdvertising;
  bool get isScanning => _isScanning;
  List<DiscoveredPeer> get discoveredPeers => _discoveredPeers.values.toList();

  /// Starts broadcasting availability for nearby challenge matches.
  Future<bool> broadcastAvailability({
    required String learnerName,
    required String languagePair,
  }) async {
    final success = await bridge.startAdvertising(
      localName: '$learnerName|$languagePair',
      serviceUuid: polyglotServiceUuid,
    );
    _isAdvertising = success;
    return success;
  }

  /// Scans for nearby learning peers broadcasting the Polyglot BLE service.
  Future<bool> startPeerDiscovery() async {
    _discoveredPeers.clear();
    final success = await bridge.startScanning(serviceUuid: polyglotServiceUuid);
    _isScanning = success;
    return success;
  }

  /// Internal callback invoked when native BLE advertisement is intercepted.
  void onAdvertisementReceived(String rawData, int rssi) {
    final parts = rawData.split('|');
    if (parts.length >= 2) {
      final peer = DiscoveredPeer(
        peerId: 'peer_${parts[0].hashCode.abs()}',
        displayName: parts[0],
        activeLanguagePair: parts[1],
        rssiSignalStrength: rssi,
        discoveredAt: DateTime.now(),
      );
      _discoveredPeers[peer.peerId] = peer;
    }
  }

  Future<void> stopAll() async {
    if (_isAdvertising) await bridge.stopAdvertising();
    if (_isScanning) await bridge.stopScanning();
    _isAdvertising = false;
    _isScanning = false;
  }
}
