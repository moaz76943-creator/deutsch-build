/// Task 1344: Catches verb second slips after 'weil' or 'dass'
class SubordinateOrderSlipDetector {
  bool isVerbSecondSlip(String subConj, int verbPosition) => (subConj == 'weil' || subConj == 'dass') && verbPosition == 2;
}
