/// Task 1656: Rotary haptic clicks when panning across 45-degree angle increments
class RotaryHapticFeedback {
  bool shouldClick(int prevDeg, int currDeg) => (currDeg ~/ 45) != (prevDeg ~/ 45);
}
