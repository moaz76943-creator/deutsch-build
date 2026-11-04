/// Task 1866: Stresses AR camera passthrough under simulated thermal throttling
class CameraThermalDropperTester {
  int calculateFps(double tempC) => tempC > 45.0 ? 8 : 24;
}
