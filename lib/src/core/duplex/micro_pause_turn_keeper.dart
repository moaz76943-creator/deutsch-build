class MicroPauseTurnKeeper {
  final int maxCognitiveHesitationMs;
  const MicroPauseTurnKeeper({this.maxCognitiveHesitationMs = 600});

  bool shouldHoldFloor(int silenceMs, bool isThoughtHesitation) {
    return isThoughtHesitation && (silenceMs <= maxCognitiveHesitationMs);
  }
}
