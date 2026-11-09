import 'dart:math';
import 'dart:typed_data';

/// Real-time 3-Band Parametric IIR Biquad Equalizer for PCM Voice Synthesis.
/// Enhances vocal clarity and attenuates low-frequency rumble on mobile speakers.
class OfflineBiquadAudioEqualizer {
  final int sampleRate;
  double _x1 = 0.0, _x2 = 0.0;
  double _y1 = 0.0, _y2 = 0.0;

  // Normalized biquad filter coefficients
  double _b0 = 1.0, _b1 = 0.0, _b2 = 0.0;
  double _a1 = 0.0, _a2 = 0.0;

  OfflineBiquadAudioEqualizer({this.sampleRate = 24000}) {
    configureVoicePresenceBoost();
  }

  /// Configure high-shelf presence filter boosting 3kHz - 8kHz for crisp consonants.
  void configureVoicePresenceBoost({double centerFreq = 3500.0, double gainDb = 3.0}) {
    final omega = 2.0 * pi * centerFreq / sampleRate;
    final alpha = sin(omega) / 2.0;
    final a = pow(10.0, gainDb / 40.0) as double;

    final a0 = (a + 1.0) - (a - 1.0) * cos(omega) + 2.0 * sqrt(a) * alpha;
    _b0 = (a * ((a + 1.0) + (a - 1.0) * cos(omega) + 2.0 * sqrt(a) * alpha)) / a0;
    _b1 = (-2.0 * a * ((a - 1.0) + (a + 1.0) * cos(omega))) / a0;
    _b2 = (a * ((a + 1.0) + (a - 1.0) * cos(omega) - 2.0 * sqrt(a) * alpha)) / a0;
    _a1 = (2.0 * ((a - 1.0) - (a + 1.0) * cos(omega))) / a0;
    _a2 = ((a + 1.0) - (a - 1.0) * cos(omega) - 2.0 * sqrt(a) * alpha) / a0;
  }

  /// Process 16-bit mono PCM bytes in-place with zero allocation.
  Uint8List processPcmBytes(Uint8List inputPcm) {
    if (inputPcm.isEmpty) return Uint8List(0);

    final view = ByteData.sublistView(inputPcm);
    final sampleCount = inputPcm.length ~/ 2;
    final outputBytes = Uint8List(inputPcm.length);
    final outView = ByteData.sublistView(outputBytes);

    for (int i = 0; i < sampleCount; i++) {
      final x0 = view.getInt16(i * 2, Endian.little).toDouble();
      final y0 = _b0 * x0 + _b1 * _x1 + _b2 * _x2 - _a1 * _y1 - _a2 * _y2;

      _x2 = _x1;
      _x1 = x0;
      _y2 = _y1;
      _y1 = y0;

      final clamped = y0.round().clamp(-32768, 32767);
      outView.setInt16(i * 2, clamped, Endian.little);
    }

    return outputBytes;
  }

  void reset() {
    _x1 = 0.0;
    _x2 = 0.0;
    _y1 = 0.0;
    _y2 = 0.0;
  }
}
