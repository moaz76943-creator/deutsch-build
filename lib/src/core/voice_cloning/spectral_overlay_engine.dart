class SpectralOverlayFrame {
  final int timeBin;
  final double nativeEnergyDbfs;
  final double learnerEnergyDbfs;
  final double spectralDelta;

  const SpectralOverlayFrame({
    required this.timeBin,
    required this.nativeEnergyDbfs,
    required this.learnerEnergyDbfs,
    required this.spectralDelta,
  });
}

class SpectralOverlayEngine {
  const SpectralOverlayEngine();

  List<SpectralOverlayFrame> generateOverlay(List<double> nativeMagnitudes, List<double> learnerMagnitudes) {
    final int count = nativeMagnitudes.length < learnerMagnitudes.length ? nativeMagnitudes.length : learnerMagnitudes.length;
    final List<SpectralOverlayFrame> frames = [];

    for (int i = 0; i < count; i++) {
      final double delta = (nativeMagnitudes[i] - learnerMagnitudes[i]).abs();
      frames.add(SpectralOverlayFrame(
        timeBin: i,
        nativeEnergyDbfs: nativeMagnitudes[i],
        learnerEnergyDbfs: learnerMagnitudes[i],
        spectralDelta: double.parse(delta.toStringAsFixed(2)),
      ));
    }
    return frames;
  }
}
