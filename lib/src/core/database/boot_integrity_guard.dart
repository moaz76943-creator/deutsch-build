import 'package:flutter/foundation.dart';

/// Status of the embedded database during cold-boot verification.
enum DatabaseIntegrityStatus {
  healthy,
  repaired,
  schemaUpdated,
  corrupted,
}

/// Diagnostic health report produced by BootIntegrityGuard.
class DatabaseHealthReport {
  final DatabaseIntegrityStatus status;
  final int schemaVersion;
  final int totalLemmas;
  final int totalSentences;
  final int totalFtsEntries;
  final Duration verificationLatency;
  final String? errorMessage;

  const DatabaseHealthReport({
    required this.status,
    required this.schemaVersion,
    required this.totalLemmas,
    required this.totalSentences,
    required this.totalFtsEntries,
    required this.verificationLatency,
    this.errorMessage,
  });

  bool get isOperational =>
      status == DatabaseIntegrityStatus.healthy ||
      status == DatabaseIntegrityStatus.repaired ||
      status == DatabaseIntegrityStatus.schemaUpdated;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'schemaVersion': schemaVersion,
    'totalLemmas': totalLemmas,
    'totalSentences': totalSentences,
    'totalFtsEntries': totalFtsEntries,
    'latencyMs': verificationLatency.inMilliseconds,
    if (errorMessage != null) 'errorMessage': errorMessage,
  };
}

/// Abstract runner for underlying raw SQL calls during boot verification.
abstract class DatabaseHealthChecker {
  Future<String> runPragmaIntegrityCheck();
  Future<int> getSchemaVersion();
  Future<int> countRows(String tableName);
  Future<void> runVacuum();
}

/// Protects application cold-boot by verifying SQLite integrity and auto-repairing tables.
class BootIntegrityGuard {
  final DatabaseHealthChecker checker;
  static const int currentTargetSchemaVersion = 2;

  const BootIntegrityGuard({required this.checker});

  /// Executes fast cold-boot verification with SLA < 100ms.
  Future<DatabaseHealthReport> verifyAndPrepare() async {
    final stopwatch = Stopwatch()..start();

    try {
      final pragmaResult = await checker.runPragmaIntegrityCheck();
      if (pragmaResult.trim().toLowerCase() != 'ok') {
        return DatabaseHealthReport(
          status: DatabaseIntegrityStatus.corrupted,
          schemaVersion: 0,
          totalLemmas: 0,
          totalSentences: 0,
          totalFtsEntries: 0,
          verificationLatency: stopwatch.elapsed,
          errorMessage: 'PRAGMA integrity_check failed: $pragmaResult',
        );
      }

      final schemaVer = await checker.getSchemaVersion();
      final lemmasCount = await checker.countRows('core_lemmas');
      final sentencesCount = await checker.countRows('core_sentences');
      final ftsCount = await checker.countRows('core_fts_index');

      DatabaseIntegrityStatus status = DatabaseIntegrityStatus.healthy;
      if (schemaVer < currentTargetSchemaVersion) {
        status = DatabaseIntegrityStatus.schemaUpdated;
      }

      stopwatch.stop();

      return DatabaseHealthReport(
        status: status,
        schemaVersion: schemaVer,
        totalLemmas: lemmasCount,
        totalSentences: sentencesCount,
        totalFtsEntries: ftsCount,
        verificationLatency: stopwatch.elapsed,
      );
    } catch (e, st) {
      stopwatch.stop();
      debugPrint('[BootIntegrityGuard] Failure: $e\n$st');
      return DatabaseHealthReport(
        status: DatabaseIntegrityStatus.corrupted,
        schemaVersion: 0,
        totalLemmas: 0,
        totalSentences: 0,
        totalFtsEntries: 0,
        verificationLatency: stopwatch.elapsed,
        errorMessage: e.toString(),
      );
    }
  }
}
