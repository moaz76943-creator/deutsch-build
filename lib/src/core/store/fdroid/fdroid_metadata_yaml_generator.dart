class FdroidMetadataYamlGenerator {
  final String appId = 'com.polyglot.sovereign';
  String generateYaml() => 'Package: $appId\nLicense: MIT\nCategories:\n  - Education\n';
}
