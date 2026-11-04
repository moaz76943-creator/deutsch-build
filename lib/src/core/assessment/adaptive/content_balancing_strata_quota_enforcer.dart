/// Task 1415: Content balancing algorithm ensuring equitable domain coverage
class ContentBalancingQuotaEnforcer {
  final Map<String, int> _counts = {};
  void recordDomainUsage(String domain) => _counts[domain] = (_counts[domain] ?? 0) + 1;
  String selectLeastRepresented(List<String> domains) => domains.reduce((a, b) => (_counts[a] ?? 0) <= (_counts[b] ?? 0) ? a : b);
}
