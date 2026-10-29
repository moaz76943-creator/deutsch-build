import '../architecture/operation_result.dart';

enum FeatureFailureReason {
  missingOfflineVoice,
  missingOptionalDictionary,
  invalidVault,
  storageIntegrity,
  networkTimeout,
  unknown,
}

abstract class FeatureRecoveryOutcome {
  const FeatureRecoveryOutcome();
}

class RecoverySuccess<T> extends FeatureRecoveryOutcome {
  final T? data;
  const RecoverySuccess([this.data]);
}

class RecoveryDegraded extends FeatureRecoveryOutcome {
  final FeatureFailureReason reason;
  final String message;
  const RecoveryDegraded(this.reason, this.message);
}

class RecoveryBlocked extends FeatureRecoveryOutcome {
  final FeatureFailureReason reason;
  final String message;
  const RecoveryBlocked(this.reason, this.message);
}

class RecoveryOutcomeHelper {
  static FeatureRecoveryOutcome classifyFailure(Object error) {
    final errorString = error.toString().toLowerCase();

    // Critical failures (fail-closed)
    if (error is StorageFailure ||
        errorString.contains('storageintegrity') ||
        errorString.contains('invalidvault')) {
      return const RecoveryBlocked(
        FeatureFailureReason.storageIntegrity,
        'Critical storage or vault integrity failure.',
      );
    }

    // Optional / Degraded failures
    if (error is ContentFailure || errorString.contains('dictionary')) {
      return const RecoveryDegraded(
        FeatureFailureReason.missingOptionalDictionary,
        'Missing content or dictionary. Feature degraded.',
      );
    }

    if (errorString.contains('offline voice') ||
        errorString.contains('voice')) {
      return const RecoveryDegraded(
        FeatureFailureReason.missingOfflineVoice,
        'Missing offline voice. Feature degraded.',
      );
    }

    if (errorString.contains('timeout') || errorString.contains('network')) {
      return const RecoveryDegraded(
        FeatureFailureReason.networkTimeout,
        'Network timeout. Feature degraded to offline mode.',
      );
    }

    return RecoveryDegraded(FeatureFailureReason.unknown, error.toString());
  }
}
