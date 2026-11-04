class FdroidFastlaneStructureBuilder {
  final String basePath = 'fastlane/metadata/android';
  String getLocalePath(String lang) => '$basePath/$lang';
}
