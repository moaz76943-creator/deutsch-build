import 'dart:io';

/// Optional override for platforms that expose free space through a native
/// MethodChannel. A null result means that the value is unavailable.
typedef FreeDiskSpaceProbe = Future<int?> Function(Directory directory);

/// Metrics for .sqlite files within the dedicated offline-pack directory.
/// Auxiliary WAL/SHM files and progress databases outside this directory are
/// intentionally excluded.
class StorageMetrics {
  final int installedPackCount;
  final int installedPackBytes;
  final int? availableDiskBytes;

  const StorageMetrics({
    required this.installedPackCount,
    required this.installedPackBytes,
    required this.availableDiskBytes,
  });
}

/// Summary of a cleanup pass. Candidate counts are also populated in dry-run
/// mode, while deletion counts and reclaimed bytes remain zero.
class StorageCleanupReport {
  final bool dryRun;
  final int partialFileCandidates;
  final int corruptedPackCandidates;
  final int deletedPartialFiles;
  final int deletedCorruptedPacks;
  final int reclaimedBytes;
  final int skippedRecentFiles;
  final int skippedChangedFiles;
  final List<String> errors;

  const StorageCleanupReport({
    required this.dryRun,
    required this.partialFileCandidates,
    required this.corruptedPackCandidates,
    required this.deletedPartialFiles,
    required this.deletedCorruptedPacks,
    required this.reclaimedBytes,
    required this.skippedRecentFiles,
    required this.skippedChangedFiles,
    required this.errors,
  });
}

/// Maintains only the caller-supplied offline-pack directory.
///
/// Pass a dedicated pack directory, never the user-progress database directory.
/// Call cleanup when installs/downloads are idle. A minimum age protects
/// in-progress atomic installs (which use .tmp files) and recent downloads.
/// SQLite verification here checks the 16-byte file signature, not PRAGMA
/// integrity_check or a pack manifest. Valid-header files are never deleted.
class StorageMaintenanceService {
  static const List<int> _sqliteSignature = <int>[
    83,
    81,
    76,
    105,
    116,
    101,
    32,
    102,
    111,
    114,
    109,
    97,
    116,
    32,
    51,
    0,
  ];

  final Directory packDirectory;
  final Duration minimumFileAge;
  final FreeDiskSpaceProbe? _freeDiskSpaceProbe;
  final DateTime Function() _clock;

  StorageMaintenanceService({
    required this.packDirectory,
    this.minimumFileAge = const Duration(hours: 24),
    FreeDiskSpaceProbe? freeDiskSpaceProbe,
    DateTime Function()? clock,
  })  : _freeDiskSpaceProbe = freeDiskSpaceProbe,
        _clock = clock ?? DateTime.now {
    if (minimumFileAge.isNegative) {
      throw ArgumentError.value(
        minimumFileAge,
        'minimumFileAge',
        'Must not be negative',
      );
    }
  }

  /// Calculates the size of regular .sqlite pack files only.
  /// Does not create a directory or open an SQLite database.
  Future<StorageMetrics> getStorageMetrics() async {
    var bytes = 0;
    var count = 0;

    if (await packDirectory.exists()) {
      await for (final entity in packDirectory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !_isSqlite(entity.path)) continue;
        if (!await _isRegularFile(entity.path)) continue;

        final stat = await entity.stat();
        count++;
        bytes += stat.size;
      }
    }

    return StorageMetrics(
      installedPackCount: count,
      installedPackBytes: bytes,
      availableDiskBytes: await getAvailableDiskSpaceBytes(),
    );
  }

  /// Returns available bytes for the filesystem containing [packDirectory].
  ///
  /// Uses an injected platform-channel probe when provided; otherwise uses
  /// dart:io Process.run with the platform's 'df' command. Returns null when
  /// this OS does not expose the value, instead of reporting a false zero.
  Future<int?> getAvailableDiskSpaceBytes() async {
    if (_freeDiskSpaceProbe != null) {
      return _freeDiskSpaceProbe!(packDirectory);
    }

    // The pack directory may not have been created yet. Query the nearest
    // existing parent, on the same app-storage filesystem.
    var directory = packDirectory.absolute;
    while (!await directory.exists()) {
      final parent = directory.parent;
      if (parent.path == directory.path) return null;
      directory = parent;
    }

    final executables =
        Platform.isAndroid ? <String>['/system/bin/df', 'df'] : <String>['df'];

    for (final executable in executables) {
      for (final flags in <String>['-kP', '-k']) {
        try {
          final result = await Process.run(
            executable,
            <String>[flags, directory.path],
          );
          if (result.exitCode != 0) continue;

          final available = _parseDfKilobytes(result.stdout.toString());
          if (available != null) return available * 1024;
        } on ProcessException {
          // Try the next supported invocation, if any.
        } on UnsupportedError {
          return null;
        }
      }
    }
    return null;
  }

  /// Removes stale partial transfers and SQLite packs with invalid headers.
  ///
  /// This operation never deletes .db, -wal, -shm, other extensions, symlinks,
  /// or valid-header SQLite files. Missing directories are treated as empty.
  /// Use dryRun to inspect candidate counts without deleting anything.
  Future<StorageCleanupReport> purgeOrphanedFiles({
    bool dryRun = false,
  }) async {
    var partialCandidates = 0;
    var corruptCandidates = 0;
    var deletedPartials = 0;
    var deletedCorrupt = 0;
    var reclaimedBytes = 0;
    var skippedRecent = 0;
    var skippedChanged = 0;
    final errors = <String>[];
    final cutoff = _clock().subtract(minimumFileAge);

    if (await packDirectory.exists()) {
      await for (final entity in packDirectory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) continue;

        final partial = _isPartial(entity.path);
        final sqlite = _isSqlite(entity.path);
        if (!partial && !sqlite) continue;

        try {
          if (!await _isRegularFile(entity.path)) continue;
          final before = await entity.stat();
          if (before.modified.isAfter(cutoff)) {
            skippedRecent++;
            continue;
          }

          if (sqlite && await _hasSqliteHeader(entity)) continue;

          if (partial) {
            partialCandidates++;
          } else {
            corruptCandidates++;
          }
          if (dryRun) continue;

          // Re-check to avoid deleting a file modified during this scan.
          if (!await _isUnchangedStaleFile(entity, before, cutoff)) {
            skippedChanged++;
            continue;
          }

          await entity.delete();
          reclaimedBytes += before.size;
          if (partial) {
            deletedPartials++;
          } else {
            deletedCorrupt++;
          }
        } on FileSystemException catch (error) {
          errors.add('${entity.path}: $error');
        } catch (error) {
          errors.add('${entity.path}: $error');
        }
      }
    }

    return StorageCleanupReport(
      dryRun: dryRun,
      partialFileCandidates: partialCandidates,
      corruptedPackCandidates: corruptCandidates,
      deletedPartialFiles: deletedPartials,
      deletedCorruptedPacks: deletedCorrupt,
      reclaimedBytes: reclaimedBytes,
      skippedRecentFiles: skippedRecent,
      skippedChangedFiles: skippedChanged,
      errors: List<String>.unmodifiable(errors),
    );
  }

  static bool _isSqlite(String path) => path.toLowerCase().endsWith('.sqlite');

  static bool _isPartial(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.tmp') ||
        lower.endsWith('.part') ||
        lower.endsWith('.downloading');
  }

  static Future<bool> _isRegularFile(String path) async {
    return await FileSystemEntity.type(
          path,
          followLinks: false,
        ) ==
        FileSystemEntityType.file;
  }

  static Future<bool> _hasSqliteHeader(File file) async {
    final handle = await file.open(mode: FileMode.read);
    try {
      final bytes = await handle.read(_sqliteSignature.length);
      if (bytes.length != _sqliteSignature.length) return false;
      for (var i = 0; i < _sqliteSignature.length; i++) {
        if (bytes[i] != _sqliteSignature[i]) return false;
      }
      return true;
    } finally {
      await handle.close();
    }
  }

  static Future<bool> _isUnchangedStaleFile(
    File file,
    FileStat previous,
    DateTime cutoff,
  ) async {
    if (!await _isRegularFile(file.path)) return false;
    final current = await file.stat();
    return current.size == previous.size &&
        current.modified == previous.modified &&
        !current.modified.isAfter(cutoff);
  }

  /// 'df -k' reports available capacity in 1024-byte blocks.
  Future<void> cleanupTemporaryFiles() async {
    await purgeOrphanedFiles();
  }

  static int? _parseDfKilobytes(String output) {
    final lines = output
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length < 2) return null;

    final columns = lines.first.split(RegExp(r'\s+'));
    final availableIndex = columns.indexWhere(
      (column) => column.toLowerCase().startsWith('avail'),
    );
    if (availableIndex < 0) return null;

    for (final line in lines.skip(1).toList().reversed) {
      final values = line.split(RegExp(r'\s+'));
      if (values.length <= availableIndex) continue;
      final kilobytes = int.tryParse(values[availableIndex]);
      if (kilobytes != null && kilobytes >= 0) return kilobytes;
    }
    return null;
  }
}
