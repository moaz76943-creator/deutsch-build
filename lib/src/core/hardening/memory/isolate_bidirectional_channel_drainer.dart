/// Task 1015: Non-blocking isolate port buffer cleanup & channel drainer
class IsolateChannelDrainer {
  bool _drained = false;
  Future<void> drainQueue() async {
    _drained = true;
  }
  bool get isDrained => _drained;
}
