final class GamificationClockIntegrityStamp {
  const GamificationClockIntegrityStamp({
    required this.elapsedRealtimeMilliseconds,
    required this.bootCount,
  });

  final int elapsedRealtimeMilliseconds;
  final int bootCount;

  bool get isValid =>
      elapsedRealtimeMilliseconds >= 0 &&
      bootCount >= 0;
}

abstract interface class GamificationClockIntegritySource {
  Future<GamificationClockIntegrityStamp?> read();
}

final class UnavailableGamificationClockIntegritySource
    implements GamificationClockIntegritySource {
  const UnavailableGamificationClockIntegritySource();

  @override
  Future<GamificationClockIntegrityStamp?> read() async => null;
}
