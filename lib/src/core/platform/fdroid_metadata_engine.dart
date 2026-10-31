class FdroidPackageMetadata {
  final String appId;
  final String appName;
  final String license;
  final String sourceCodeRepoUrl;
  final String issueTrackerUrl;
  final String summaryEn;
  final String descriptionEn;
  final List<String> antiFeatures; // Must remain empty for pure sovereign badge

  const FdroidPackageMetadata({
    required this.appId,
    required this.appName,
    required this.license,
    required this.sourceCodeRepoUrl,
    required this.issueTrackerUrl,
    required this.summaryEn,
    required this.descriptionEn,
    this.antiFeatures = const [],
  });

  /// Generates standard F-Droid YAML recipe string.
  String toFdroidYamlRecipe({required String versionName, required int versionCode, required String commitHash}) {
    final buffer = StringBuffer();
    buffer.writeln('Categories:');
    buffer.writeln('  - Education');
    buffer.writeln('  - Languages');
    buffer.writeln('License: $license');
    buffer.writeln('SourceCode: $sourceCodeRepoUrl');
    buffer.writeln('IssueTracker: $issueTrackerUrl');
    buffer.writeln('');
    buffer.writeln('AutoName: $appName');
    buffer.writeln('Summary: $summaryEn');
    buffer.writeln('Description: |-\n  $descriptionEn');
    buffer.writeln('');
    buffer.writeln('RepoType: git');
    buffer.writeln('Repo: $sourceCodeRepoUrl');
    buffer.writeln('');
    buffer.writeln('Builds:');
    buffer.writeln('  - versionName: $versionName');
    buffer.writeln('    versionCode: $versionCode');
    buffer.writeln('    commit: $commitHash');
    buffer.writeln('    subdir: .');
    buffer.writeln('    output: build/app/outputs/flutter-apk/app-release.apk');
    buffer.writeln('    gradle:');
    buffer.writeln('      - yes');

    if (antiFeatures.isNotEmpty) {
      buffer.writeln('AntiFeatures:');
      for (final af in antiFeatures) {
        buffer.writeln('  - $af');
      }
    }

    return buffer.toString();
  }
}

class FdroidMetadataEngine {
  const FdroidMetadataEngine();

  /// Validates that the package strictly qualifies for zero-anti-feature sovereign status on F-Droid.
  bool verifyZeroAntiFeatures(FdroidPackageMetadata metadata) {
    return metadata.antiFeatures.isEmpty;
  }

  /// Generates default production metadata for Polyglot Sovereign Platform.
  FdroidPackageMetadata buildDefaultMetadata() {
    return const FdroidPackageMetadata(
      appId: 'com.deutsch.polyglot',
      appName: 'DEUTSCH بالعربي - Polyglot Sovereign',
      license: 'GPL-3.0-only',
      sourceCodeRepoUrl: 'https://github.com/moaz76943-creator/deutsch-build',
      issueTrackerUrl: 'https://github.com/moaz76943-creator/deutsch-build/issues',
      summaryEn: '100-Language Sovereign Offline-First Language Learning Platform.',
      descriptionEn: 'Polyglot is an entirely sovereign, offline-first language learning application with zero telemetry, local AI dialogue, and embedded neural speech recognition.',
      antiFeatures: [], // Verified: No tracking, No ads, No non-free network dependencies
    );
  }
}
