class PackDependencyResolutionEngine {
  final Map<String, List<String>> dependencies = {};
  bool areDependenciesSatisfied(String packId, Set<String> installedPacks) {
    final reqs = dependencies[packId] ?? [];
    return installedPacks.containsAll(reqs);
  }
}
