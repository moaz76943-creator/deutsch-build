class DeltaDifferentialPackUpdater {
  const DeltaDifferentialPackUpdater();
  List<int> applyDeltaPatch(List<int> baseBytes, List<int> patchBytes) =>
      List.from(baseBytes)..addAll(patchBytes);
}
