/// Task 1807: Graceful degradation policy for low-end devices
class GracefulDegradationPolicy {
  String getQualityTier(int availableRamMb) => availableRamMb < 256 ? 'LOW' : 'HIGH';
}
