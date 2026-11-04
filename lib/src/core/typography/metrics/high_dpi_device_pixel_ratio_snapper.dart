/// Task 1266: Snaps geometry to whole physical device pixels on high-DPI displays
class HighDpiPixelSnapper {
  double snapToDevicePixel(double logical, double dpr) => (logical * dpr).round() / dpr;
}
