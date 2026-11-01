class DynamicStoryWorldSimulator {
  final Map<String, String> _scenes = {};
  void registerScene(String id, String text) => _scenes[id] = text;
  String? getScene(String id) => _scenes[id];
}
