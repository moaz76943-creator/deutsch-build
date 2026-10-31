import 'package:test/test.dart';
import '../../lib/src/content/local_mesh_pack_share_protocol.dart';

void main() {
  group('LocalMeshPackShareProtocol Unit Tests (L086)', () {
    final protocol = LocalMeshPackShareProtocol();

    test('Discovers and resolves newest language pack from nearby mesh peers', () {
      protocol.registerPackAdvertisement(const MeshPackAdvertisement(
        peerDeviceId: 'peer_tablet_01',
        packId: 'de_ar_a1',
        packVersion: 1,
        packSizeBytes: 15000000,
        sha256Checksum: 'hash1',
      ));
      protocol.registerPackAdvertisement(const MeshPackAdvertisement(
        peerDeviceId: 'peer_laptop_02',
        packId: 'de_ar_a1',
        packVersion: 2,
        packSizeBytes: 15500000,
        sha256Checksum: 'hash2',
      ));

      expect(protocol.availablePacksCount, equals(2));

      final source = protocol.findBestSource('de_ar_a1', 1);
      expect(source, isNotNull);
      expect(source!.packVersion, equals(2));
      expect(source.peerDeviceId, equals('peer_laptop_02'));
    });

    test('Returns null when requested pack is not found in mesh neighborhood', () {
      expect(protocol.findBestSource('unknown_pack', 1), isNull);
    });
  });
}
