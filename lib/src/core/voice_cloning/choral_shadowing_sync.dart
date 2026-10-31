class ChoralShadowingSync {
  double calculateAlignmentDelay(double learnerLeadSec, double modelLeadSec) {
    return (learnerLeadSec - modelLeadSec).abs();
  }
}
