/// Task 1038: Tombstone-based deleted item reconciler for offline mesh sync
class TombstoneReconciler {
  final Set<String> _tombstones = {};
  void markDeleted(String id) => _tombstones.add(id);
  bool isDeleted(String id) => _tombstones.contains(id);
}
