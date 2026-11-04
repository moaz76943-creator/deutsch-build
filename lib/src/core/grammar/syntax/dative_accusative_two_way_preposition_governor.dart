/// Task 1312: Wechselpräpositionen governor (Motion -> Akk, Location -> Dat)
class TwoWayPrepositionGovernor {
  String resolveCase(bool isDirectionalMovement) => isDirectionalMovement ? 'Akkusativ' : 'Dativ';
}
