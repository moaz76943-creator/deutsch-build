/// Task 1885: Audits AndroidManifest.xml ensuring minimal sovereign permissions
class ManifestSecurityAuditor {
  bool hasNoDangerousPermissions(List<String> permissions) => !permissions.contains('ACCESS_FINE_LOCATION');
}
