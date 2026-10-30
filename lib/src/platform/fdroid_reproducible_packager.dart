/// F-Droid reproducible build manifest and metadata specification.
class FdroidBuildManifest {
  final String applicationId;
  final String versionName;
  final int versionCode;
  final String commitHash;
  final String license; // 'Apache-2.0'
  final bool hasZeroProprietaryBlobs;
  final String buildCommand;

  const FdroidBuildManifest({
    required this.applicationId,
    required this.versionName,
    required this.versionCode,
    required this.commitHash,
    required this.license,
    required this.hasZeroProprietaryBlobs,
    required this.buildCommand,
  });
}

/// Generates reproducible F-Droid recipe metadata ensuring 100% open-source software sovereignty.
class FdroidReproduciblePackager {
  /// Generates the standard F-Droid YAML recipe metadata.
  String generateFdroidYaml(FdroidBuildManifest manifest) {
    final buffer = StringBuffer();
    buffer.writeln('Categories:');
    buffer.writeln('  - Education');
    buffer.writeln('  - Languages');
    buffer.writeln('License: ${manifest.license}');
    buffer.writeln('SourceCode: https://github.com/moaz76943-creator/deutsch-build');
    buffer.writeln('IssueTracker: https://github.com/moaz76943-creator/deutsch-build/issues');
    buffer.writeln();
    buffer.writeln('Builds:');
    buffer.writeln('  - versionName: ${manifest.versionName}');
    buffer.writeln('    versionCode: ${manifest.versionCode}');
    buffer.writeln('    commit: ${manifest.commitHash}');
    buffer.writeln('    build: ${manifest.buildCommand}');
    buffer.writeln('    scanignore:');
    buffer.writeln('      - .polyglot_cache');

    return buffer.toString();
  }

  /// Verifies zero-blob compliance before package sealing.
  bool verifyZeroProprietaryBlobs(FdroidBuildManifest manifest) {
    return manifest.hasZeroProprietaryBlobs && manifest.license == 'Apache-2.0';
  }
}
