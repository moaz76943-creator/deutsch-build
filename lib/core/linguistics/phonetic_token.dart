class PhoneticToken {
  final String rawText;
  final String ipaRepresentation;
  final String audioAssetKey;
  final double pitchMultiplier;

  const PhoneticToken({
    required this.rawText,
    required this.ipaRepresentation,
    required this.audioAssetKey,
    this.pitchMultiplier = 1.0,
  });
}
