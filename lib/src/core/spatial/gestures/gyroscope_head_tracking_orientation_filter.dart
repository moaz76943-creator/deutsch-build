/// Task 1643: Device IMU gyroscope orientation filter for 360 panoramic inspection
class GyroscopeOrientationFilter {
  List<double> filterOrientation(double gx, double gy, double gz) => [gx * 0.98, gy * 0.98, gz * 0.98];
}
