import 'package:flutter/foundation.dart';

import '../domain/error_pattern_models.dart';
import '../domain/error_pattern_repository.dart';

enum ErrorPatternState { idle, loading, analyzed }

final class ErrorPatternNotifier extends ChangeNotifier {
  ErrorPatternNotifier({
    required ErrorPatternRepository repository,
  }) : _repository = repository;

  final ErrorPatternRepository _repository;

  ErrorPatternState _state = ErrorPatternState.idle;
  BlindSpotSummary? _summary;
  List<ErrorLogEntry> _recentErrors = const <ErrorLogEntry>[];
  int _sequence = 0;

  ErrorPatternState get state => _state;
  BlindSpotSummary? get summary => _summary;
  List<ErrorLogEntry> get recentErrors => _recentErrors;

  Future<void> recordFailure(
    ErrorCategory category,
    String item,
  ) async {
    final now = DateTime.now().toUtc();
    final normalizedItem = item.trim();
    if (normalizedItem.isEmpty) {
      throw ArgumentError.value(item, 'item', 'must not be empty');
    }

    _setState(ErrorPatternState.loading);
    try {
      await _repository.logError(
        ErrorLogEntry(
          id: 'error-${now.microsecondsSinceEpoch}-${_sequence++}',
          category: category,
          item: normalizedItem,
          context: 'learning-session',
          timestamp: now,
        ),
      );
      await _loadAnalysis();
    } on Object {
      _setState(ErrorPatternState.idle);
      rethrow;
    }
  }

  Future<void> refreshAnalysis() async {
    _setState(ErrorPatternState.loading);
    try {
      await _loadAnalysis();
    } on Object {
      _setState(ErrorPatternState.idle);
      rethrow;
    }
  }

  Future<void> _loadAnalysis() async {
    final results = await Future.wait<Object?>(<Future<Object?>>[
      _repository.getRecentErrors(),
      _repository.analyzeBlindSpots(),
    ]);

    _recentErrors = List<ErrorLogEntry>.unmodifiable(
      results[0]! as List<ErrorLogEntry>,
    );
    _summary = results[1] as BlindSpotSummary?;
    _setState(ErrorPatternState.analyzed);
  }

  void _setState(ErrorPatternState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }
}
