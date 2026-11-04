/// Task 1808: Thread-safe immutable configuration registry
class MicrokernelConfigRegistry {
  final Map<String, String> _config = {};
  String? get(String key) => _config[key];
}
