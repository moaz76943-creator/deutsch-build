/// Task 1092: Bypassing damaged language pack chunks during startup
class CorruptedAssetBypassController {
  final Set<String> _badPacks = {};
  void flagBadPack(String id) => _badPacks.add(id);
  bool shouldBypass(String id) => _badPacks.contains(id);
}
