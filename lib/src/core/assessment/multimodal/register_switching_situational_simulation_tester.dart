/// Task 1495: Tests fluid register switching (casual chat -> formal report)
class RegisterSwitchingTester {
  bool isSwitchCorrect(String context, bool usedFormal) => (context == 'meeting' && usedFormal) || (context == 'break_room' && !usedFormal);
}
