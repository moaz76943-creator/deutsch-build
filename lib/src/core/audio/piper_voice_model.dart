/// Specification for an onnx-quantized Piper neural voice model.
class PiperVoiceModel {
  final String modelId; // e.g. "de_DE-thorsten-low"
  final String languageIso; // "de"
  final String speakerName;
  final int sampleRate; // Usually 22050 or 16000
  final int numSpeakers;
  final String qualityTier; // "low", "medium", "high"
  final String assetPath;

  const PiperVoiceModel({
    required this.modelId,
    required this.languageIso,
    required this.speakerName,
    required this.sampleRate,
    this.numSpeakers = 1,
    this.qualityTier = 'low',
    required this.assetPath,
  });

  Map<String, dynamic> toJson() => {
    'modelId': modelId,
    'languageIso': languageIso,
    'speakerName': speakerName,
    'sampleRate': sampleRate,
    'numSpeakers': numSpeakers,
    'qualityTier': qualityTier,
    'assetPath': assetPath,
  };
}
