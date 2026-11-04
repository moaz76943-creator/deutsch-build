/// Task 1053: Ambient noise floor calibrator for accurate VAD speech detection
class VadEnergyCalibrator {
  double noiseFloorDb = -45.0;
  void calibrateFloor(double ambientDb) => noiseFloorDb = ambientDb;
  bool isSpeech(double signalDb) => signalDb > (noiseFloorDb + 10.0);
}
