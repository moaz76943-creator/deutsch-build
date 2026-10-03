import '../domain/error_pattern_models.dart';
import '../domain/error_pattern_repository.dart';

final class LocalErrorPatternRepository implements ErrorPatternRepository {
  LocalErrorPatternRepository({this.capacity = 500}) {
    if (capacity < 1 || capacity > 5000) {
      throw ArgumentError.value(capacity, 'capacity', 'must be 1..5000');
    }
  }

  final int capacity;
  final List<ErrorLogEntry> _entries = <ErrorLogEntry>[];

  @override
  Future<void> logError(ErrorLogEntry entry) async {
    _entries.removeWhere((existing) => existing.id == entry.id);
    _entries.add(entry);
    _entries.sort(_compareChronologically);

    if (_entries.length > capacity) {
      _entries.removeRange(0, _entries.length - capacity);
    }
  }

  @override
  Future<List<ErrorLogEntry>> getRecentErrors({int limit = 50}) async {
    final safeLimit = limit.clamp(0, capacity).toInt();
    if (safeLimit == 0 || _entries.isEmpty) {
      return const <ErrorLogEntry>[];
    }

    final start = (_entries.length - safeLimit)
        .clamp(0, _entries.length)
        .toInt();
    final recent = _entries.sublist(start).reversed.toList(growable: false);
    return List<ErrorLogEntry>.unmodifiable(recent);
  }

  @override
  Future<BlindSpotSummary?> analyzeBlindSpots() async {
    if (_entries.isEmpty) return null;

    final counts = <ErrorCategory, int>{
      for (final category in ErrorCategory.values) category: 0,
    };
    final latestByCategory = <ErrorCategory, DateTime>{};

    for (final entry in _entries) {
      counts[entry.category] = (counts[entry.category] ?? 0) + 1;
      final currentLatest = latestByCategory[entry.category];
      if (currentLatest == null || entry.timestamp.isAfter(currentLatest)) {
        latestByCategory[entry.category] = entry.timestamp;
      }
    }

    final ranked = ErrorCategory.values.toList(growable: false)
      ..sort((left, right) {
        final countComparison =
            (counts[right] ?? 0).compareTo(counts[left] ?? 0);
        if (countComparison != 0) return countComparison;

        final leftLatest = latestByCategory[left];
        final rightLatest = latestByCategory[right];
        if (leftLatest != null && rightLatest != null) {
          final recentComparison = rightLatest.compareTo(leftLatest);
          if (recentComparison != 0) return recentComparison;
        } else if (leftLatest == null && rightLatest != null) {
          return 1;
        } else if (leftLatest != null && rightLatest == null) {
          return -1;
        }

        return left.index.compareTo(right.index);
      });

    final top = ranked.first;
    final topCount = counts[top] ?? 0;
    final percentage = topCount / _entries.length * 100;

    return BlindSpotSummary(
      topCategory: top,
      frequencyPercentage: percentage.clamp(0.0, 100.0).toDouble(),
      adviceAr: _adviceFor(top),
    );
  }

  static int _compareChronologically(
    ErrorLogEntry left,
    ErrorLogEntry right,
  ) {
    final time = left.timestamp.compareTo(right.timestamp);
    return time != 0 ? time : left.id.compareTo(right.id);
  }

  static String _adviceFor(ErrorCategory category) {
    return switch (category) {
      ErrorCategory.genderConfusion =>
        'راجع الاسم مع أداته الأصلية كل مرة، ثم اختبر der/die/das قبل متابعة الجملة.',
      ErrorCategory.caseMismatch =>
        'حدّد الحالة الإعرابية أولًا، ثم طبّق شكل الأداة المناسب قبل اختيار الإجابة.',
      ErrorCategory.wordOrderDrift =>
        'ثبّت موقع الفعل المصرف، ثم ابنِ بقية الجملة حوله بدل ترتيب الكلمات كلمةً بكلمة.',
      ErrorCategory.prepositionError =>
        'احفظ حرف الجر مع الحالة التي يطلبها، وميّز في الحروف الثنائية بين Wo وWohin.',
    };
  }
}
