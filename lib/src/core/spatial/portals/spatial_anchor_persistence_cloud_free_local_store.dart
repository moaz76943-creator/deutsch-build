/// Task 1684: Zero-cloud local persistence of AR spatial anchors
class LocalSpatialAnchorStore {
  final Map<String, List<double>> _anchors = {};
  void saveAnchor(String id, List<double> matrix) => _anchors[id] = matrix;
}
