class AudioTrack {
  final String id;
  final String assetPath;
  final String languageCode;
  final int durationMs;
  final bool hasLocalFallback;

  const AudioTrack({
    required this.id,
    required this.assetPath,
    required this.languageCode,
    required this.durationMs,
    required this.hasLocalFallback,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioTrack &&
        other.id == id &&
        other.assetPath == assetPath &&
        other.languageCode == languageCode &&
        other.durationMs == durationMs &&
        other.hasLocalFallback == hasLocalFallback;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        assetPath.hashCode ^
        languageCode.hashCode ^
        durationMs.hashCode ^
        hasLocalFallback.hashCode;
  }
}
