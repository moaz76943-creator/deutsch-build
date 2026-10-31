/// Manifest advertisement payload broadcasted over local Wi-Fi / BLE mesh.
class MeshPackAdvertisement {
  final String peerDeviceId;
  final String packId;
  final int packVersion;
  final int packSizeBytes;
  final String sha256Checksum;

  const MeshPackAdvertisement({
    required this.peerDeviceId,
    required this.packId,
    required this.packVersion,
    required this.packSizeBytes,
    required this.sha256Checksum,
  });
}

/// Zero-internet local mesh protocol enabling classrooms and community hubs to share language packs.
class LocalMeshPackShareProtocol {
  final Map<String, MeshPackAdvertisement> _discoveredPacks = {};

  int get availablePacksCount => _discoveredPacks.length;

  /// Ingests a local mDNS / BLE beacon advertisement.
  void registerPackAdvertisement(MeshPackAdvertisement ad) {
    final key = '${ad.packId}_${ad.packVersion}';
    _discoveredPacks[key] = ad;
  }

  /// Finds best local peer source for a missing language pack.
  MeshPackAdvertisement? findBestSource(String packId, int minimumVersion) {
    MeshPackAdvertisement? best;
    for (final ad in _discoveredPacks.values) {
      if (ad.packId == packId && ad.packVersion >= minimumVersion) {
        if (best == null || ad.packVersion > best.packVersion) {
          best = ad;
        }
      }
    }
    return best;
  }
}
