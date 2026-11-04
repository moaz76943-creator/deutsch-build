class AtomicStateSnapshotCompactBuffer {
  final List<int> compactStateBytes = [];
  void saveState(List<int> bytes) {
    compactStateBytes..clear()..addAll(bytes.take(2048));
  }
}
