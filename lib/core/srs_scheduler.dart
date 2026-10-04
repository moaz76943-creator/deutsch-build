import '../models/learner.dart';
import 'worker/persistent_cpu_worker.dart';
import 'worker/worker_contract.dart';

abstract interface class SrsScheduler {
  Future<ReviewCard> schedule(
    ReviewCard current, {
    required bool correct,
    required bool hinted,
    DateTime? now,
  });
}

final class SrsScheduleFailure implements Exception {
  const SrsScheduleFailure(this.code);

  final String code;

  @override
  String toString() => 'SrsScheduleFailure($code)';
}

/// Canonical scheduling boundary.
///
/// All schedule calculations are delegated to the one persistent CPU worker.
/// There is deliberately no synchronous/main-isolate algorithm fallback.
final class UnifiedSrsScheduler implements SrsScheduler {
  const UnifiedSrsScheduler({PersistentCpuWorker? worker})
      : _worker = worker;

  final PersistentCpuWorker? _worker;

  @override
  Future<ReviewCard> schedule(
    ReviewCard current, {
    required bool correct,
    required bool hinted,
    DateTime? now,
  }) async {
    if (!current.facetKey.isValid) {
      throw const SrsScheduleFailure('invalid_review_card');
    }

    final worker = _worker ?? PersistentCpuWorker.active;
    if (worker == null || worker.isClosed) {
      throw const SrsScheduleFailure(
        'persistent_cpu_worker_unavailable',
      );
    }

    final at = (now ?? DateTime.now()).toUtc();
    final epoch = worker.currentEpoch;
    final result = await worker.submit<Map<String, Object?>>(
      WorkerJob<Map<String, Object?>>(
        id: 'srs.$epoch.${at.microsecondsSinceEpoch}',
        type: WorkerJobTypes.srsSchedule,
        epoch: epoch,
        payload: <String, Object?>{
          'card': current.toJson(),
          'correct': correct,
          'hinted': hinted,
          'now': at.toIso8601String(),
        },
      ),
    );

    if (result.status != WorkerStatuses.ok ||
        result.payload == null) {
      throw SrsScheduleFailure(
        result.errorCode ?? result.status,
      );
    }

    return ReviewCard.fromJson(
      Map<String, dynamic>.from(result.payload!),
    );
  }

  int xpRewardForReview({
    required bool correct,
    required bool hinted,
  }) {
    if (!correct) return 2;
    return hinted ? 6 : 10;
  }
}

const UnifiedSrsScheduler unifiedSrsScheduler =
    UnifiedSrsScheduler();
