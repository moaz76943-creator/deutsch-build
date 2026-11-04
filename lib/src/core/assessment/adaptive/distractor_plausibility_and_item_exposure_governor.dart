/// Task 1406: Item exposure rate controller & distractor plausibility
class ItemExposureGovernor {
  bool isExposureSafe(int impressions, int totalTests) => totalTests > 0 ? (impressions / totalTests) < 0.25 : true;
}
