import 'error_pattern_models.dart';

abstract interface class ErrorDiagnosticRepository {
  Future<List<ErrorLogEntry>> loadEntries();
  Future<void> appendEntry(ErrorLogEntry entry);
  Future<void> clearEntries();
}

abstract interface class ErrorDiagnosticSink {
  Future<void> recordFailure(LearningFailureSignal signal);
}

final class NoopErrorDiagnosticSink implements ErrorDiagnosticSink {
  const NoopErrorDiagnosticSink();

  @override
  Future<void> recordFailure(LearningFailureSignal signal) async {}
}
