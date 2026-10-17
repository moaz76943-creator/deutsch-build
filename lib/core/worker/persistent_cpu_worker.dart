import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PersistentCpuWorker with WidgetsBindingObserver {
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();

  static const int maxQueueSize = 100;
  static const int _maxTasks = 50;
  static const int maxTasks = 50;

  int _pendingJobs = 0;
  int _activeTasks = 0;
  int _generation = 0;
  bool _isDisposed = false;

  PersistentCpuWorker._init() {
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}
  }

  int get activeTasks => _activeTasks > 0 ? _activeTasks : _pendingJobs;
  int get pendingJobs => _pendingJobs;
  int get generation => _generation;
  bool get isDisposed => _isDisposed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      cancelAll();
    }
  }

  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    return await enqueue(_heavySrsMath, {'ease': currentEase, 'rating': rating});
  }

  /// Generic bounded isolated execution method
  Future<R> enqueue<T, R>(ComputeCallback<T, R> callback, T message) async {
    if (_isDisposed) {
      throw StateError('Worker is disposed');
    }
    if (_pendingJobs >= maxQueueSize || _activeTasks >= _maxTasks) {
      throw StateError('Worker queue exhausted: Queue capacity reached');
    }
    _pendingJobs++;
    _activeTasks++;
    final currentGeneration = _generation;

    await Future.delayed(Duration.zero);

    try {
      final result = await compute(callback, message);
      if (currentGeneration != _generation) {
        throw StateError('Task cancelled: Job cancelled or stale generation');
      }
      return result;
    } finally {
      _pendingJobs--;
      _activeTasks--;
    }
  }

  /// Cancel all currently in-flight isolated jobs by incrementing the generation.
  void cancelAll() {
    _generation++;
  }

  void dispose() {
    _isDisposed = true;
    _generation++;
    cancelAll();
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTesting() {
    _generation = 0;
    _activeTasks = 0;
    _pendingJobs = 0;
    _isDisposed = false;
  }
}

// دالة حساب مصفوفة التكرار (SM-2 Logic)
double _heavySrsMath(Map<String, dynamic> params) {
  final double currentEase = (params['ease'] as num).toDouble();
  final int rating = params['rating'] as int;
  double newEase = currentEase + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
  if (newEase < 1.3) newEase = 1.3;
  return newEase;
}
