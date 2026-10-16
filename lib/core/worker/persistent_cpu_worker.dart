import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// عامل المعالجة المعزول لضمان عدم تجميد الواجهة أثناء حسابات SRS
class PersistentCpuWorker with WidgetsBindingObserver {
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();
  
  int _pendingJobs = 0;
  int _generation = 0;
  static const int maxQueueSize = 100;
  bool _isDisposed = false;

  PersistentCpuWorker._init() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    return await enqueue(_heavySrsMath, {'ease': currentEase, 'rating': rating});
  }

  /// Generic bounded isolated execution method
  Future<R> enqueue<T, R>(ComputeCallback<T, R> callback, T message) async {
    if (_isDisposed) {
      throw StateError('Worker is disposed');
    }
    if (_pendingJobs >= maxQueueSize) {
      throw StateError('Queue capacity reached');
    }

    _pendingJobs++;
    final currentGeneration = _generation;

    try {
      final result = await compute(callback, message);
      if (currentGeneration != _generation) {
        throw StateError('Job cancelled or stale generation');
      }
      return result;
    } finally {
      _pendingJobs--;
    }
  }

  /// Cancel all currently in-flight isolated jobs by incrementing the generation.
  void cancelAll() {
    _generation++;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      cancelAll();
    }
  }

  void dispose() {
    _isDisposed = true;
    cancelAll();
    WidgetsBinding.instance.removeObserver(this);
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
