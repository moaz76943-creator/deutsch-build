/// Task 1081: Top-level RunZonedGuarded error trap preventing VM crashes
class GlobalErrorZoneAbsorber {
  int absorbedErrors = 0;
  void absorb(Object error, StackTrace trace) => absorbedErrors++;
  bool get hasErrors => absorbedErrors > 0;
}
