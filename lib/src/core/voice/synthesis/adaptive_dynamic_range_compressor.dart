import 'dart:math';
import 'dart:typed_data';

/// Feed-forward soft-knee Dynamic Range Compressor (DRC) for speech playback.
/// Normalizes quiet whisper phonemes and suppresses harsh acoustic spikes.
class AdaptiveDynamicRangeCompressor {
  final double thresholdDb;
  final double ratio;
  final double attackCoeff;
  final double releaseCoeff;
  double _envelope = 0.0;

  AdaptiveDynamicRangeCompressor({
    this.thresholdDb = -18.0,
    this.ratio = 4.0,
    this.attackCoeff = 0.85,
    this.releaseCoeff = 0.995,
  });

  /// Process 16-bit mono PCM bytes in-place with zero memory allocation.
  Uint8List processPcmBytes(Uint8List inputPcm) {
    if (inputPcm.isEmpty) return Uint8List(0);

    final view = ByteData.sublistView(inputPcm);
    final sampleCount = inputPcm.length ~/ 2;
    final outputBytes = Uint8List(inputPcm.length);
    final outView = ByteData.sublistView(outputBytes);

    final thresholdLinear = pow(10.0, thresholdDb / 20.0) * 32767.0;

    for (int i = 0; i < sampleCount; i++) {
      final inputSample = view.getInt16(i * 2, Endian.little);
      final absSample = inputSample.abs().toDouble();

      // Envelope follower
      if (absSample > _envelope) {
        _envelope = attackCoeff * _envelope + (1.0 - attackCoeff) * absSample;
      } else {
        _envelope = releaseCoeff * _envelope + (1.0 - releaseCoeff) * absSample;
      }

      // Gain computation
      double gain = 1.0;
      if (_envelope > thresholdLinear) {
        final overDb = 20.0 * log(_envelope / thresholdLinear) / ln10;
        final compressedDb = overDb / ratio;
        final gainDb = compressedDb - overDb;
        gain = pow(10.0, gainDb / 20.0) as double;
      }

      final compressedSample = (inputSample * gain).round().clamp(-32768, 32767);
      outView.setInt16(i * 2, compressedSample, Endian.little);
    }

    return outputBytes;
  }
}
