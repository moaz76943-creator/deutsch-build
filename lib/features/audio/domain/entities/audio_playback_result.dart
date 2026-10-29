enum AudioPlaybackSource { recorded, offlineTts, unavailable }

final class AudioPlaybackResult {
  const AudioPlaybackResult._({required this.source, this.reason});

  const AudioPlaybackResult.recorded()
      : this._(source: AudioPlaybackSource.recorded);

  const AudioPlaybackResult.offlineTts()
      : this._(source: AudioPlaybackSource.offlineTts);

  const AudioPlaybackResult.unavailable(String reason)
      : this._(source: AudioPlaybackSource.unavailable, reason: reason);

  final AudioPlaybackSource source;
  final String? reason;

  bool get played => source != AudioPlaybackSource.unavailable;
}
