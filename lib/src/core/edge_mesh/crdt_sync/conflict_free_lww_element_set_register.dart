/// Task 2031: Last-Write-Wins (LWW) element set CRDT resolving study progress
class LwwElementSetRegister {
  final Map<String, int> _addSet = {};
  void addElement(String id, int timestamp) => _addSet[id] = timestamp;
  bool contains(String id) => _addSet.containsKey(id);
}
