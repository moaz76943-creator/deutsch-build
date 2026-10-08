// Pack Format & Manifest Contract - Post-V1 Expansion
// Defines the immutable distribution artifact manifest structure

class PackManifestContract {
  final String packId;
  final String languageId;
  final String version;
  final int schemaVersion;
  final String archiveHash;
  final int compressedSize;

  const PackManifestContract({
    required this.packId,
    required this.languageId,
    required this.version,
    required this.schemaVersion,
    required this.archiveHash,
    required this.compressedSize,
  });

  bool validateManifest() {
    return packId.isNotEmpty && languageId.isNotEmpty && archiveHash.isNotEmpty;
  }
}
