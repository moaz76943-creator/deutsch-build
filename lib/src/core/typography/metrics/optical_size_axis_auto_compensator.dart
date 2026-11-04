/// Task 1264: OpenType 'opsz' optical size axis compensator
class OpticalSizeCompensator {
  double getOpsz(double ptSize) => ptSize.clamp(6.0, 72.0);
}
