import 'package:flutter/foundation.dart';

import '../domain/error_diagnostic_repository.dart';
import '../domain/error_pattern_analyzer.dart';
import '../domain/error_pattern_models.dart';

final class ErrorPatternAgentNotifier extends ChangeNotifier
    implements ErrorDiagnosticSink {
  ErrorPatternAgentNotifier(
    this._repository, {
    ErrorPatternAnalyzer analyzer = const ErrorPatternAnalyzer(),
    DateTime Function()? now,
  })  : _analyzer = analyzer,
        _now = now ?? DateTime.now;

  final ErrorDiagnosticRepository _repository;
  final ErrorPatternAnalyzer _analyzer;
  final DateTime Function() _now;

  List<ErrorLogEntry> _entries = const <ErrorLogEntry>[];
  BlindSpotReport _report = BlindSpotReport(
    generatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    totalErrors: 0,
    topBlindSpots: const <BlindSpotDiagnostic>[],
  );
  bool _initialized = false;
  bool _busy = false;
  String? _lastError;

  List<ErrorLogEntry> get entries => List.unmodifiable(_entries);
  BlindSpotReport get report => _report;
  bool get initialized => _initialized;
  bool get busy => _busy;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    if (_initialized || _busy) return;
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      _entries = await _repository.loadEntries();
      _report = _analyzer.buildReport(_entries, now: _now());
      _initialized = true;
    } on Object {
      _lastError = 'تعذر تحميل سجل التشخيص المحلي.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  Future<void> recordFailure(LearningFailureSignal signal) async {
    final entry = _analyzer.entryFromSignal(signal);
    if (entry == null) return;
    try {
      await _repository.appendEntry(entry);
      final next = <ErrorLogEntry>[..._entries, entry];
      _entries = List.unmodifiable(
        next.length <= LocalDiagnosticPolicy.maxInMemoryEntries
            ? next
            : next.sublist(
                next.length - LocalDiagnosticPolicy.maxInMemoryEntries,
              ),
      );
      _report = _analyzer.buildReport(_entries, now: _now());
      _initialized = true;
      _lastError = null;
      notifyListeners();
    } on Object {
      _lastError = 'تعذر حفظ حدث التشخيص محلياً.';
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      await _repository.clearEntries();
      _entries = const <ErrorLogEntry>[];
      _report = _analyzer.buildReport(_entries, now: _now());
    } on Object {
      _lastError = 'تعذر مسح سجل التشخيص المحلي.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

abstract final class LocalDiagnosticPolicy {
  static const int maxInMemoryEntries = 500;
}
