import 'dart:typed_data';

/// High-efficiency, zero-drift linear interpolation resampler for raw PCM audio.
/// Optimized for edge and low-power Android/Termux environments.
class PcmAdaptiveSampleRateConverter {
  final int sourceSampleRate;
  final int targetSampleRate;

  PcmAdaptiveSampleRateConverter({
    required this.sourceSampleRate,
    required this.targetSampleRate,
  }) {
    if (sourceSampleRate <= 0 || targetSampleRate <= 0) {
      throw ArgumentError('Sample rates must be positive integers');
    }
  }

  /// Resample 16-bit mono PCM bytes to target sample rate without phase drift.
  Uint8List resample16BitMono(Uint8List inputPcm) {
    if (sourceSampleRate == targetSampleRate || inputPcm.isEmpty) {
      return Uint8List.fromList(inputPcm);
    }

    final inputSamplesCount = inputPcm.length ~/ 2;
    if (inputSamplesCount == 0) return Uint8List(0);

    final inputView = ByteData.sublistView(inputPcm);
    final ratio = targetSampleRate / sourceSampleRate;
    final outputSamplesCount = (inputSamplesCount * ratio).round();

    final outputData = ByteData(outputSamplesCount * 2);

    for (int i = 0; i < outputSamplesCount; i++) {
      final srcIndex = i / ratio;
      final indexFloor = srcIndex.floor();
      final fraction = srcIndex - indexFloor;

      final s1 = inputView.getInt16(indexFloor * 2, Endian.little);
      final s2 = (indexFloor + 1 < inputSamplesCount)
          ? inputView.getInt16((indexFloor + 1) * 2, Endian.little)
          : s1;

      // Linear interpolation clamped to 16-bit signed range
      final interpolated = (s1 + (s2 - s1) * fraction).round().clamp(-32768, 32767);
      outputData.setInt16(i * 2, interpolated, Endian.little);
    }

    return outputData.buffer.asUint8List();
  }
}
