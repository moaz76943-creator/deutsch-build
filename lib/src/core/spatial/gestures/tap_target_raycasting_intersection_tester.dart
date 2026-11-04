/// Task 1644: Screen-to-world 3D raycast collision tester
class RaycastIntersectionTester {
  bool hitsSphere(double rayX, double rayY, double sphereX, double sphereY, double radius) {
    double distSq = (rayX - sphereX) * (rayX - sphereX) + (rayY - sphereY) * (rayY - sphereY);
    return distSq <= radius * radius;
  }
}
