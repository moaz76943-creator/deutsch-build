import 'package:deutsch_bilarabi/features/error_pattern_agent/application/error_pattern_notifier.dart';
import 'package:deutsch_bilarabi/features/error_pattern_agent/data/local_error_pattern_repository.dart';
import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_pattern_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ErrorLogEntry entry({
    required String id,
    required ErrorCategory category,
    required int minute,
    String item = 'der Tisch',
  }) {
    return ErrorLogEntry(
      id: id,
      category: category,
      item: item,
      context: 'unit-test',
      timestamp: DateTime.utc(2026, 10, 3, 18, minute),
    );
  }

  test('records an error and returns it from recent history', () async {
    final repository = LocalErrorPatternRepository();

    await repository.logError(
      entry(
        id: 'e1',
        category: ErrorCategory.genderConfusion,
        minute: 1,
      ),
    );

    final recent = await repository.getRecentErrors();
    expect(recent, hasLength(1));
    expect(recent.single.id, 'e1');
    expect(recent.single.category, ErrorCategory.genderConfusion);
  });

  test('groups errors and calculates dominant pattern percentage exactly', () async {
    final repository = LocalErrorPatternRepository();
    final categories = <ErrorCategory>[
      ErrorCategory.caseMismatch,
      ErrorCategory.genderConfusion,
      ErrorCategory.caseMismatch,
      ErrorCategory.caseMismatch,
    ];

    for (var index = 0; index < categories.length; index++) {
      await repository.logError(
        entry(
          id: 'e$index',
          category: categories[index],
          minute: index,
        ),
      );
    }

    final summary = await repository.analyzeBlindSpots();

    expect(summary, isNotNull);
    expect(summary!.topCategory, ErrorCategory.caseMismatch);
    expect(summary.frequencyPercentage, closeTo(75.0, 0.000001));
  });

  test('diagnostic report produces category-specific Arabic guidance', () async {
    final repository = LocalErrorPatternRepository();

    await repository.logError(
      entry(
        id: 'p1',
        category: ErrorCategory.prepositionError,
        minute: 1,
        item: 'auf + Dativ',
      ),
    );
    await repository.logError(
      entry(
        id: 'p2',
        category: ErrorCategory.prepositionError,
        minute: 2,
        item: 'in + Akkusativ',
      ),
    );

    final summary = await repository.analyzeBlindSpots();

    expect(summary, isNotNull);
    expect(summary!.topCategory, ErrorCategory.prepositionError);
    expect(summary.frequencyPercentage, 100.0);
    expect(summary.adviceAr, contains('حرف الجر'));
    expect(summary.adviceAr, contains('الحالة'));
  });

  test('duplicate ids are replaced instead of double-counted', () async {
    final repository = LocalErrorPatternRepository();

    await repository.logError(
      entry(
        id: 'same',
        category: ErrorCategory.genderConfusion,
        minute: 1,
      ),
    );
    await repository.logError(
      entry(
        id: 'same',
        category: ErrorCategory.wordOrderDrift,
        minute: 2,
      ),
    );

    final recent = await repository.getRecentErrors();
    final summary = await repository.analyzeBlindSpots();

    expect(recent, hasLength(1));
    expect(recent.single.category, ErrorCategory.wordOrderDrift);
    expect(summary?.topCategory, ErrorCategory.wordOrderDrift);
    expect(summary?.frequencyPercentage, 100.0);
  });

  test('notifier records failure and refreshes analyzed state', () async {
    final repository = LocalErrorPatternRepository();
    final notifier = ErrorPatternNotifier(repository: repository);

    await notifier.recordFailure(
      ErrorCategory.genderConfusion,
      'die Lampe',
    );

    expect(notifier.state, ErrorPatternState.analyzed);
    expect(notifier.summary?.topCategory, ErrorCategory.genderConfusion);
    expect(notifier.summary?.frequencyPercentage, 100.0);
    expect(notifier.recentErrors, hasLength(1));
  });
}
