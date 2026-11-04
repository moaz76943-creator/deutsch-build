/// Task 1586: Altruistic mesh seeding incentive calculator
class SeedRatioCalculator {
  double computeRatio(int uploadedBytes, int downloadedBytes) => downloadedBytes > 0 ? uploadedBytes / downloadedBytes : 1.0;
}
