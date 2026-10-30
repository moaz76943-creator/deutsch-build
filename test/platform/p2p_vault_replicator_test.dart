import 'package:test/test.dart';
import '../../lib/src/platform/p2p_vault_replicator.dart';

void main() {
  group('P2pVaultReplicator Unit Tests (N086)', () {
    final replicator = P2pVaultReplicator();

    test('Registers local discovered peers over WiFi Direct and BLE', () {
      replicator.addPeer(const PeerDevice(
        deviceId: 'phone_01',
        deviceName: 'Pixel 8 Pro',
        connectionMedium: 'WiFi_Direct',
        lastSyncTimestampMs: 1700000000,
      ));

      expect(replicator.peerCount, equals(1));
    });

    test('Identifies when two devices are completely in sync', () {
      final delta = replicator.computeSyncDelta(
        localVaultVersion: 10,
        remoteVaultVersion: 10,
        localItemsCount: 500,
        remoteItemsCount: 500,
      );

      expect(delta['status'], equals('in_sync'));
      expect(delta['needsTransfer'], isFalse);
      expect(delta['itemsToReplicate'], equals(0));
    });

    test('Computes replication delta when remote device has newer reviews', () {
      final delta = replicator.computeSyncDelta(
        localVaultVersion: 10,
        remoteVaultVersion: 12,
        localItemsCount: 500,
        remoteItemsCount: 540,
      );

      expect(delta['status'], equals('pull_required'));
      expect(delta['needsTransfer'], isTrue);
      expect(delta['itemsToReplicate'], equals(40));
    });
  });
}
