import 'package:deutsch_bilarabi/features/error_pattern_agent/application/error_pattern_agent_notifier.dart';
import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_diagnostic_repository.dart';
import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_pattern_models.dart';
import 'package:flutter_test/flutter_test.dart';

final class _MemoryRepository implements ErrorDiagnosticRepository {
  final List<ErrorLogEntry> entries = <ErrorLogEntry>[];

  @override
  Future<void> appendEntry(ErrorLogEntry entry) async => entries.add(entry);

  @override
  Future<void> clearEntries() async => entries.clear();

  @override
  Future<List<ErrorLogEntry>> loadEntries() async =>
      List<ErrorLogEntry>.from(entries);
}

void main() {
  test('classified failures persist and refresh the blind spot report', () async {
    final repository = _MemoryRepository();
    final notifier = ErrorPatternAgentNotifier(
      repository,
      now: () => DateTime.utc(2026, 10, 3, 12),
    );
    await notifier.initialize();

    await notifier.recordFailure(
      LearningFailureSignal(
        source: ErrorEventSource.grammar,
        skillTag: 'case_dative',
        expected: 'dem',
        actual: 'den',
        focus: 'Mann',
        occurredAt: DateTime.utc(2026, 10, 3, 11),
      ),
    );

    expect(repository.entries, hasLength(1));
    expect(notifier.report.totalErrors, 1);
    expect(
      notifier.report.topBlindSpots.single.type,
      ErrorPatternType.caseMismatch,
    );
  });

  test('unrelated failures are ignored instead of being over-diagnosed', () async {
    final repository = _MemoryRepository();
    final notifier = ErrorPatternAgentNotifier(repository);

    await notifier.recordFailure(
      LearningFailureSignal(
        source: ErrorEventSource.flashcard,
        skillTag: 'translation',
        expected: 'بيت',
        actual: 'سيارة',
        focus: 'Haus',
        occurredAt: DateTime.utc(2026, 10, 3, 11),
      ),
    );

    expect(repository.entries, isEmpty);
    expect(notifier.report.totalErrors, 0);
  });

  test('clear removes persisted and in-memory diagnostics', () async {
    final repository = _MemoryRepository();
    repository.entries.add(
      ErrorLogEntry(
        id: 'e1',
        type: ErrorPatternType.wordOrderDrift,
        focus: 'V2',
        expected: 'Heute gehe ich',
        actual: 'Heute ich gehe',
        source: ErrorEventSource.grammar,
        timestamp: DateTime.utc(2026, 10, 3),
      ),
    );
    final notifier = ErrorPatternAgentNotifier(repository);
    await notifier.initialize();
    expect(notifier.report.totalErrors, 1);

    await notifier.clear();

    expect(repository.entries, isEmpty);
    expect(notifier.report.totalErrors, 0);
  });
}
