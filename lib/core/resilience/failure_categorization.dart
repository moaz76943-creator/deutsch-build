import '../architecture/operation_result.dart';
import 'failure_reasons.dart';

class FailureCategorization {
  static bool isCritical(Object error) {
    if (error is StorageFailure) return true;
    if (error is InvalidVaultFailure) return true;

    final str = error.toString().toLowerCase();
    if (str.contains('vault corruption') || str.contains('data integrity check failed')) return true;

    return false;
  }

  static bool isRecoverable(Object error) {
    return !isCritical(error);
  }
}
