/// Task 1588: In-memory searcher for instant offline discovery of micro-packs
class OfflinePackCatalogSearcher {
  final List<String> _packs = [];
  void registerPack(String name) => _packs.add(name);
  List<String> search(String query) => _packs.where((p) => p.toLowerCase().contains(query.toLowerCase())).toList();
}
