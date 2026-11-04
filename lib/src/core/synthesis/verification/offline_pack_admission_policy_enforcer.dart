/// Task 1843: Zero-trust offline pack admission gatekeeper verifying schema compliance
class OfflinePackAdmissionPolicyEnforcer {
  bool isAdmissible(Map<String, dynamic> metadata) => metadata.containsKey('version') && metadata.containsKey('locale');
}
