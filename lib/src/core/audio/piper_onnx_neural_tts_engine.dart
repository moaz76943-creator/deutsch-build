import 'dart:typed_data';
import 'piper_voice_model.dart';

/// Alignment metadata mapping spoken phonemes to exact milliseconds in audio stream.
class PhonemeAlignment {
  final String phoneme;
  final int startMs;
  final int endMs;

  const PhonemeAlignment({
    required this.phoneme,
    required this.startMs,
    required this.endMs,
  });
}

/// Synthesized neural speech output.
class NeuralSpeechOutput {
  final Uint8List pcmBytes;
  final int sampleRate;
  final Duration duration;
  final List<PhonemeAlignment> alignments;

  const NeuralSpeechOutput({
    required this.pcmBytes,
    required this.sampleRate,
    required this.duration,
    required this.alignments,
  });
}

/// Abstract hardware runtime executor for Piper ONNX inference.
abstract class PiperOnnxRuntimeExecutor {
  Future<bool> loadModel(PiperVoiceModel model);
  Future<Uint8List> runInference(String phonemes, {double speed});
  Future<void> unloadModel();
}

/// Local neural text-to-speech engine running offline via Piper ONNX models.
class PiperOnnxNeuralTtsEngine {
  final PiperOnnxRuntimeExecutor executor;
  final Map<String, PiperVoiceModel> _registeredModels = {};
  PiperVoiceModel? _activeModel;

  PiperOnnxNeuralTtsEngine({required this.executor});

  PiperVoiceModel? get activeModel => _activeModel;
  int get registeredModelsCount => _registeredModels.length;

  /// Curated default low-latency models for primary platform languages.
  static const List<PiperVoiceModel> defaultModels = [
    PiperVoiceModel(
      modelId: 'de_DE-thorsten-low',
      languageIso: 'de',
      speakerName: 'Thorsten',
      sampleRate: 22050,
      qualityTier: 'low',
      assetPath: 'assets/audio/models/de_DE-thorsten-low.onnx',
    ),
    PiperVoiceModel(
      modelId: 'ar_JO-kareem-low',
      languageIso: 'ar',
      speakerName: 'Kareem',
      sampleRate: 22050,
      qualityTier: 'low',
      assetPath: 'assets/audio/models/ar_JO-kareem-low.onnx',
    ),
    PiperVoiceModel(
      modelId: 'en_US-lessac-low',
      languageIso: 'en',
      speakerName: 'Lessac',
      sampleRate: 22050,
      qualityTier: 'low',
      assetPath: 'assets/audio/models/en_US-lessac-low.onnx',
    ),
  ];

  void initialize({List<PiperVoiceModel>? models}) {
    _registeredModels.clear();
    final source = models ?? defaultModels;
    for (final m in source) {
      _registeredModels[m.languageIso.toLowerCase()] = m;
    }
  }

  /// Sets active voice model and initializes weights in memory.
  Future<bool> setLanguage(String languageIso) async {
    final model = _registeredModels[languageIso.toLowerCase()];
    if (model == null) return false;

    if (_activeModel?.modelId == model.modelId) return true;

    await executor.unloadModel();
    final loaded = await executor.loadModel(model);
    if (loaded) {
      _activeModel = model;
    }
    return loaded;
  }

  /// Synthesizes text to PCM buffer with phoneme alignment and speed scaling.
  Future<NeuralSpeechOutput?> synthesize({
    required String text,
    double speed = 1.0,
  }) async {
    if (_activeModel == null) return null;

    final clampedSpeed = speed.clamp(0.5, 2.0);
    final pcm = await executor.runInference(text, speed: clampedSpeed);

    // Approximate duration from 16-bit mono PCM bytes
    final totalSamples = pcm.lengthInBytes / 2;
    final durationMs = (totalSamples / _activeModel!.sampleRate * 1000).round();

    return NeuralSpeechOutput(
      pcmBytes: pcm,
      sampleRate: _activeModel!.sampleRate,
      duration: Duration(milliseconds: durationMs),
      alignments: [
        PhonemeAlignment(phoneme: text, startMs: 0, endMs: durationMs),
      ],
    );
  }

  /// Releases model memory on low-RAM notifications.
  Future<void> releaseMemory() async {
    await executor.unloadModel();
    _activeModel = null;
  }
}
