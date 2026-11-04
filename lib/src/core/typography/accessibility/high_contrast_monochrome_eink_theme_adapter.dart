/// Task 1284: Pure 1-bit monochrome high-contrast theme optimizer
class MonochromeEInkAdapter {
  int getPixel1Bit(int luminance) => luminance > 128 ? 0xFFFFFFFF : 0xFF000000;
}
