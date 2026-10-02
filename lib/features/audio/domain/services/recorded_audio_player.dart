abstract interface class RecordedAudioPlayer {
  Future<bool> playAsset(String assetPath);
  Future<void> stop();
  Future<void> shutdown();
}

final class UnavailableRecordedAudioPlayer implements RecordedAudioPlayer {
  const UnavailableRecordedAudioPlayer();

  @override
  Future<bool> playAsset(String assetPath) async => false;

  @override
  Future<void> stop() async {}

  @override
  Future<void> shutdown() async {}
}
