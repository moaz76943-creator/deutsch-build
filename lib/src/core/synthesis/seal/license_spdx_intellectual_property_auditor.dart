/// Task 1887: Scans dependencies for MIT/Apache/BSD license compliance
class SpdxLicenseAuditor {
  bool isCompliant(String license) => ['MIT', 'APACHE-2.0', 'BSD-3-CLAUSE'].contains(license.toUpperCase());
}
