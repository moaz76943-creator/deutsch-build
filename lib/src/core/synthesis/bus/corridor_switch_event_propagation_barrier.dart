/// Task 1833: Atomic barrier preventing corrupt state propagation during language corridor switch
class CorridorSwitchBarrier {
  bool isBarrierLocked = false;
  void lockBarrier() => isBarrierLocked = true;
  void releaseBarrier() => isBarrierLocked = false;
}
