/// Task 1132: Real-time speaker energy tracker discriminating user from noise
class SpeakerEnergyTracker {
  double thresholdDb = -30.0;
  bool isUserActive(double energyDb) => energyDb > thresholdDb;
}
