/// Task 1581: Schema validator for standalone offline lesson micro-packs
class MicroPackManifestValidator {
  bool validateManifest(Map<String, dynamic> manifest) => manifest.containsKey('packId') && manifest.containsKey('version') && manifest.containsKey('chunks');
}
