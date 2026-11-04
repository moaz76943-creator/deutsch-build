/// Task 1282: Daltonization filter adapting syntax highlights
enum ColorVisionDeficiency { normal, protanopia, deuteranopia, tritanopia }
class DaltonizationFilter {
  int adaptColor(int rgb, ColorVisionDeficiency cvd) => cvd == ColorVisionDeficiency.normal ? rgb : (rgb | 0x0000FF);
}
