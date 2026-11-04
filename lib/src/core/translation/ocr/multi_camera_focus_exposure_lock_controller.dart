/// Task 1772: Camera focus, ISO exposure lock and torch control for crisp OCR
class CameraFocusExposureController {
  bool isExposureLocked = false;
  void lockParameters() => isExposureLocked = true;
}
