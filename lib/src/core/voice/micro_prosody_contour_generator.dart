class MicroProsodyContourGenerator {
  const MicroProsodyContourGenerator();
  List<double> generatePitchContour(String text, int sampleCount) => List.filled(sampleCount, 150.0);
}
