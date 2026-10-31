import 'package:test/test.dart';
import 'package:deutsch_build/src/core/multiplayer/local_ble_matchmaker.dart';

class MockBleBridge implements BlePlatformBridge {
  bool advertising = false;
  bool scanning = false;

  @override
  Future<bool> startAdvertising({required String localName, required String serviceUuid}) async {
    advertising = true;
    return true;
  }

  @override
  Future<void> stopAdvertising() async {
    advertising = false;
  }

  @override
  Future<bool> startScanning({required String serviceUuid}) async {
    scanning = true;
    return true;
  }

  @override
  Future<void> stopScanning() async {
    scanning = false;
  }
}

void main() {
  group('LocalBleMatchmaker Tests', () {
    late MockBleBridge bridge;
    late LocalBleMatchmaker matchmaker;

    setUp(() {
      bridge = MockBleBridge();
      matchmaker = LocalBleMatchmaker(bridge: bridge);
    });

    test('Broadcasts availability and parses discovered peer advertisement', () async {
      final broadcastOk = await matchmaker.broadcastAvailability(
        learnerName: 'Ahmad',
        languagePair: 'ar_de',
      );
      expect(broadcastOk, isTrue);
      expect(matchmaker.isAdvertising, isTrue);

      final scanOk = await matchmaker.startPeerDiscovery();
      expect(scanOk, isTrue);

      // Simulate packet arrival from nearby learner
      matchmaker.onAdvertisementReceived('Sara|ar_de', -52);

      expect(matchmaker.discoveredPeers.length, equals(1));
      expect(matchmaker.discoveredPeers.first.displayName, equals('Sara'));
      expect(matchmaker.discoveredPeers.first.activeLanguagePair, equals('ar_de'));
    });
  });
}
