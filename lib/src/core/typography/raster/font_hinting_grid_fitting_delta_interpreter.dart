/// Task 1224: TrueType bytecode hinting and grid-fitting delta interpreter
class FontHintingInterpreter {
  double snapToGrid(double coordinate, double pixelSize) => (coordinate / pixelSize).round() * pixelSize;
}
