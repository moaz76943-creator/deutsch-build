import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

typedef LearningReviewWriter = Future<void> Function({
  required String learnerContentId,
  required String targetLanguageCode,
  required int grade,
});

enum ReviewSubmissionStatus { accepted, duplicate, unavailable }

/// Session-level duplicate protection in front of the existing SRS authority.
///
/// Scheduling and persistence remain owned by DatabaseService/Route 15. This
/// class only prevents repeated UI callbacks from writing the same review twice.
class LearningReviewCoordinator {
  LearningReviewCoordinator({LearningReviewWriter? writer})
      : _writer = writer ?? _writeThroughExistingSrs;

  final LearningReviewWriter _writer;
  final Set<String> _inFlightEvents = <String>{};
  final Set<String> _completedEvents = <String>{};
  bool _disposed = false;

  static Future<void> _writeThroughExistingSrs({
    required String learnerContentId,
    required String targetLanguageCode,
    required int grade,
  }) async {
    await DatabaseService.instance.gradeAndPersistSrs(
      lexemeId: learnerContentId,
      languageCode: targetLanguageCode,
      grade: grade,
    );
  }

  Future<ReviewSubmissionStatus> submit({
    required String eventId,
    required String learnerContentId,
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required int grade,
  }) async {
    if (_disposed) {
      return ReviewSubmissionStatus.unavailable;
    }
    if (eventId.trim().isEmpty || learnerContentId.trim().isEmpty) {
      throw ArgumentError('Review identity cannot be empty');
    }
    if (grade < 0 || grade > 4) {
      throw RangeError.range(grade, 0, 4, 'grade');
    }

    final source = _normalizeLanguage(sourceLanguageCode);
    final target = _normalizeLanguage(targetLanguageCode);
    final pair = DirectedPairId(
      sourceLocale: source,
      targetLocale: target,
      semanticVersion: 'review-v1',
    );
    if (!pair.isValidForLearning()) {
      throw ArgumentError('A directed learning pair is required');
    }

    final eventKey = '${pair.uniqueKey}::${eventId.trim()}';
    if (_completedEvents.contains(eventKey) ||
        _inFlightEvents.contains(eventKey)) {
      return ReviewSubmissionStatus.duplicate;
    }

    _inFlightEvents.add(eventKey);
    try {
      await _writer(
        learnerContentId: learnerContentId.trim(),
        targetLanguageCode: target,
        grade: grade,
      );
      _completedEvents.add(eventKey);
      return ReviewSubmissionStatus.accepted;
    } finally {
      _inFlightEvents.remove(eventKey);
    }
  }

  void dispose() {
    _disposed = true;
  }

  static String _normalizeLanguage(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      throw ArgumentError.value(value, 'languageCode', 'Invalid language code');
    }
    return normalized;
  }
}
