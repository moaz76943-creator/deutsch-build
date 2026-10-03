import 'error_pattern_models.dart';

abstract class ErrorPatternRepository {
  Future<void> logError(ErrorLogEntry entry);

  Future<List<ErrorLogEntry>> getRecentErrors({int limit = 50});

  Future<BlindSpotSummary?> analyzeBlindSpots();
}
