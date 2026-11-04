/// Task 1775: Adaptive frame-skip governor balancing OCR quality with battery temperature
class OcrFrameSkipGovernor {
  int getTargetFps(double batteryTempCelsius) => batteryTempCelsius > 42.0 ? 5 : 15;
}
