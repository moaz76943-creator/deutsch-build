class PolyglotPackageFormatSpecification {
  static const String magicHeader = 'POLYGLOT_SOV_PACK';
  static const int currentVersion = 1;
  final int totalEntries;
  const PolyglotPackageFormatSpecification({this.totalEntries = 0});
}
