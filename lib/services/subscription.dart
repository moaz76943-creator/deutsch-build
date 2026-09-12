/// Paid entitlements are intentionally not trusted from local storage.
/// Until Google Play Billing (with server/store verification) is integrated,
/// the app never treats a local boolean as proof of payment.
class SubscriptionService {
  static const hasPublicLocalEntitlementMutation = false;
  static const billingReady = false;

  static Future<bool> isPremium() async => false;
}
