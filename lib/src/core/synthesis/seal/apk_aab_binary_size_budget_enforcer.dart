/// Task 1882: Enforces binary size budget (<65MB base APK) preventing bloat
class BinarySizeBudgetEnforcer {
  bool isWithinBudget(int apkSizeBytes) => apkSizeBytes <= (65 * 1024 * 1024);
}
