final class PerformanceSample {
  const PerformanceSample({
    required this.operation,
    required this.elapsedMicros,
  });

  final String operation;
  final int elapsedMicros;
}

final class PerformanceProfile {
  const PerformanceProfile({
    required this.operation,
    required this.count,
    required this.totalMicros,
    required this.averageMicros,
    required this.maxMicros,
    required this.p95Micros,
    required this.budgetMicros,
  });

  final String operation;
  final int count;
  final int totalMicros;
  final double averageMicros;
  final int maxMicros;
  final int p95Micros;
  final int? budgetMicros;

  bool get budgetExceeded =>
      budgetMicros != null && p95Micros > budgetMicros!;
}

final class PerformanceProfiler {
  const PerformanceProfiler();

  List<PerformanceProfile> profile(
    List<PerformanceSample> samples, {
    Map<String, int> budgetsMicros = const <String, int>{},
  }) {
    final grouped = <String, List<int>>{};

    for (final sample in samples) {
      if (sample.elapsedMicros < 0) {
        throw ArgumentError.value(
          sample.elapsedMicros,
          'elapsedMicros',
          'Performance timings cannot be negative.',
        );
      }
      grouped.putIfAbsent(sample.operation, () => <int>[])
        ..add(sample.elapsedMicros);
    }

    final operations = grouped.keys.toList()..sort();
    return List<PerformanceProfile>.unmodifiable(
      operations.map((operation) {
        final values = List<int>.from(grouped[operation]!)..sort();
        final total = values.fold<int>(0, (sum, value) => sum + value);
        final rawP95 = (values.length * 0.95).ceil() - 1;
        final p95Index = rawP95 < 0 ? 0 : rawP95;

        return PerformanceProfile(
          operation: operation,
          count: values.length,
          totalMicros: total,
          averageMicros: total / values.length,
          maxMicros: values.last,
          p95Micros: values[p95Index],
          budgetMicros: budgetsMicros[operation],
        );
      }),
    );
  }
}
