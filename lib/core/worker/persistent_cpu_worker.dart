import 'package:flutter/foundation.dart';

/// عامل المعالجة المعزول لضمان عدم تجميد الواجهة أثناء حسابات SRS
class PersistentCpuWorker {
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();

  PersistentCpuWorker._init();

  static const int _maxTasks = 50;
  int _activeTasks = 0;
  int _generation = 0;

  int get activeTasks => _activeTasks;
  int get generation => _generation;

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    if (_activeTasks >= _maxTasks) {
      throw StateError('Worker queue exhausted');
    }

    final int currentGeneration = _generation;
    _activeTasks++;

    // Yield control to the event loop before heavy isolate setup
    await Future.delayed(Duration.zero);

    try {
      // نقل الحسابات الثقيلة إلى Isolate مستقل باستخدام compute
      final result = await compute(_heavySrsMath, {'ease': currentEase, 'rating': rating});

      if (_generation != currentGeneration) {
        throw StateError('Task cancelled');
      }

      return result;
    } finally {
      _activeTasks--;
    }
  }

  void cancelAll() {
    _generation++;
  }

  void dispose() {
    _generation++;
  }

  @visibleForTesting
  void resetForTesting() {
    _generation = 0;
    _activeTasks = 0; // Forcefully clear only for test setup boundaries
  }

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  static double _heavySrsMath(Map<String, dynamic> data) {
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;

    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    return newEase;
  }
}
