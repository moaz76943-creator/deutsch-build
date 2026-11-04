/// Task 1665: Places antonyms at opposite ends of room axes (warm/kalt)
class PolarAxisAligner {
  Map<String, double> getAntonymOffset(bool isNegativePolarity) => {'zOffset': isNegativePolarity ? -5.0 : 5.0};
}
