/// Task 1016: Idle background worker suspend and memory release manager
class BackgroundWorkerQuiescenceController {
  bool _quiescent = false;
  void enterQuiescence() => _quiescent = true;
  void resumeActivity() => _quiescent = false;
  bool get isQuiescent => _quiescent;
}
