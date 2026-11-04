/// Task 1635: Maps F1, F2, F3 acoustic formants to 3D spherical clusters
class FormantClusterMapper {
  List<double> getClusterCenter(double f1, double f2, double f3) => [f1 * 0.001, f2 * 0.001, f3 * 0.001];
}
