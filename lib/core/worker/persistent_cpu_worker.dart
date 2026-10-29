import 'package:flutter/foundation.dart';

class WorkerQueueExhaustedException implements Exception {
  final String message;
  WorkerQueueExhaustedException(this.message);
  @override
  String toString() => 'WorkerQueueExhaustedException: $message';
}

class WorkerCancelledException implements Exception {
  final String message;
  WorkerCancelledException(this.message);
  @override
  String toString() => 'WorkerCancelledException: $message';
}

/// عامل المعالجة المعزول لضمان عدم تجميد الواجهة أثناء حسابات SRS
class PersistentCpuWorker {
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();
  
  PersistentCpuWorker._init();

  int _maxQueueSize = 50;
  int _activeJobs = 0;
  int _currentGeneration = 0;
  bool _isDisposed = false;

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    if (_isDisposed) {
      throw StateError('Worker is disposed');
    }

    if (_activeJobs >= _maxQueueSize) {
      throw WorkerQueueExhaustedException('Queue limit reached ($_maxQueueSize)');
    }

    _activeJobs++;
    final int generationToken = _currentGeneration;

    try {
      // نقل الحسابات الثقيلة إلى Isolate مستقل باستخدام compute
      final result = await compute(_heavySrsMath, {'ease': currentEase, 'rating': rating});

      if (_isDisposed || generationToken != _currentGeneration) {
        throw WorkerCancelledException('Job cancelled or worker disposed');
      }

      return result;
    } finally {
      _activeJobs--;
    }
  }

  void cancelCurrentGeneration() {
    _currentGeneration++;
  }

  void setMaxQueueSize(int size) {
    _maxQueueSize = size;
  }

  void reset() {
    _maxQueueSize = 50;
    _activeJobs = 0;
    _currentGeneration = 0;
    _isDisposed = false;
  }

  void dispose() {
    _isDisposed = true;
    _currentGeneration++; // invalidate any running jobs
  }

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  static double _heavySrsMath(Map<String, dynamic> data) {
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;
    
    if (ease < 0) {
      throw ArgumentError('Ease cannot be negative');
    }

    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;
    
    return newEase;
  }
}
