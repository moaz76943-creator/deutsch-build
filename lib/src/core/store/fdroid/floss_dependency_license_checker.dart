class FlossDependencyLicenseChecker {
  final Set<String> approvedLicenses = {'MIT', 'Apache-2.0', 'BSD-3-Clause'};
  bool isFlossCompliant(String license) => approvedLicenses.contains(license);
}
