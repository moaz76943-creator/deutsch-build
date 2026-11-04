class IsolateHeapQuarantineSupervisor {
  final int maxHeapMb;
  const IsolateHeapQuarantineSupervisor({this.maxHeapMb = 40});
  bool shouldRecycleIsolate(int currentHeapMb) => currentHeapMb > maxHeapMb;
}
