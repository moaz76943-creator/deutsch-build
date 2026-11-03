/// Task 1137: Cross-correlation delay estimator between DAC playout and ADC capture
class CircularDelayEstimator {
  int estimatedDelayMs = 24;
  void updateDelay(int dacTs, int adcTs) => estimatedDelayMs = (adcTs - dacTs).abs();
}
