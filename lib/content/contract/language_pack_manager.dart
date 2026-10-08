// Language Pack Manager - Post-V1 Expansion
// Coordinates pack lifecycle, installation state, and runtime availability

import 'content_contracts.dart';

class LanguagePackManager {
  final Map<String, PackLoader> _loaders = {};

  void registerPack(String packId) {
    if (!_loaders.containsKey(packId)) {
      _loaders[packId] = PackLoader(packId: packId);
    }
  }

  Future<bool> activatePack(String packId) async {
    final loader = _loaders[packId];
    if (loader == null) return false;
    return await loader.installPack();
  }

  bool isPackActive(String packId) {
    return _loaders[packId]?.isInstalled ?? false;
  }
}
