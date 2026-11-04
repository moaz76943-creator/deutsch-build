/// Task 1608: 3D spatial audio reverb zone calculator
class SpatialReverbZone {
  double calculateReverbDecay(double roomVolumeM3) => (roomVolumeM3 * 0.01).clamp(0.2, 3.5);
}
