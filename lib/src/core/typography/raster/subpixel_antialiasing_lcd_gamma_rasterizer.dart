/// Task 1221: Subpixel LCD RGB stripe anti-aliasing with gamma correction
class SubpixelGammaRasterizer {
  double correctGamma(double linearVal, double gamma) => linearVal > 0 ? linearVal : 0.0;
}
