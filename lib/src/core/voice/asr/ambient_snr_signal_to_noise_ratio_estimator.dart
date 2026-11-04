/// Task 1148: SNR estimator warning user when microphone is noisy
class SnrEstimator {
  double estimateSnr(double signalDb, double noiseDb) => signalDb - noiseDb;
  bool isQualitySufficient(double snr) => snr >= 15.0;
}
