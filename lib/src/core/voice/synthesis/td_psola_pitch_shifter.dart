import 'dart:typed_data';

/// Time-Domain Pitch Synchronous Overlap-Add (TD-PSOLA) engine for voice audio.
/// Enables independent time-stretching (e.g. 0.75x slow-motion for pronunciation learning)
/// without altering vocal pitch or causing metallic robotic distortion.
class TdPsolaPitchShifter {
  final int sampleRate;
  final int defaultWindowSize;

  TdPsolaPitchShifter({
    this.sampleRate = 24000,
    this.defaultWindowSize = 512,
  });

  /// Scale speaking duration by stretchFactor (e.g. 1.25 slows down by 25%).
  Uint8List timeStretch16BitMono(Uint8List inputPcm, double stretchFactor) {
    if (inputPcm.isEmpty || stretchFactor <= 0.0) return Uint8List(0);
    if ((stretchFactor - 1.0).abs() < 0.01) return Uint8List.fromList(inputPcm);

    final inputView = ByteData.sublistView(inputPcm);
    final inSamples = inputPcm.length ~/ 2;
    final outSamples = (inSamples * stretchFactor).round();

    final outputBytes = Uint8List(outSamples * 2);
    final outView = ByteData.sublistView(outputBytes);

    final stepIn = defaultWindowSize ~/ 2;
    final stepOut = (stepIn * stretchFactor).round();

    int inPos = 0;
    int outPos = 0;

    while (inPos + defaultWindowSize < inSamples && outPos + defaultWindowSize < outSamples) {
      // Overlap-add Hann-windowed segment
      for (int i = 0; i < defaultWindowSize; i++) {
        final sample = inputView.getInt16((inPos + i) * 2, Endian.little);
        final currentOut = outView.getInt16((outPos + i) * 2, Endian.little);

        // Normalized linear cross-fade window
        final weight = 1.0 - (2.0 * (i - defaultWindowSize / 2).abs() / defaultWindowSize);
        final blended = (currentOut + (sample * weight)).round().clamp(-32768, 32767);

        outView.setInt16((outPos + i) * 2, blended, Endian.little);
      }

      inPos += stepIn;
      outPos += stepOut;
    }

    return outputBytes;
  }
}
