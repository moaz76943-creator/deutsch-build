/// Task 1123: Frequency-domain spectral subtraction of microphone speaker leakage
class SpectralEchoSubtractor {
  double subtractLeakage(double micMagnitude, double echoEstimate) => (micMagnitude - echoEstimate).clamp(0.0, 1.0);
}
