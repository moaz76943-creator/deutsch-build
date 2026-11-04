class PackCatalogSemanticSearchEngine {
  final List<String> availableLangs = ['العربية', 'التركية', 'الإندونيسية', 'الألمانية', 'الإنجليزية'];
  List<String> findPacks(String query) => availableLangs.where((l) => l.contains(query)).toList();
}
