/// Task 1596: Sandboxes newly received chunks in a quarantine buffer
class QuarantineSandboxInspector {
  final Map<String, List<int>> _quarantine = {};
  void holdChunk(String chunkId, List<int> bytes) => _quarantine[chunkId] = bytes;
  List<int>? releaseIfValid(String chunkId, bool isValid) => isValid ? _quarantine.remove(chunkId) : null;
}
