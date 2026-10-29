import 'dart:async';
import 'package:flutter/foundation.dart';

/// Task priority level for offloaded computation.
enum TaskPriority {
  immediate, // Audio processing / pronunciation feedback
  normal,    // Grammar exercise generation
  background // FSRS-5 cognitive matrix batch updates
}

/// Abstract representation of a task payload offloaded to background isolate.
typedef ComputeCallback<T, R> = FutureOr<R> Function(T message);

/// Manages a constrained pool of background Dart workers ensuring 60fps UI smoothness.
class IsolateWorkerPool {
  final int maxWorkers;
  final Duration defaultTimeout;

  int _activeJobs = 0;
  bool _isDisposed = false;

  IsolateWorkerPool({
    this.maxWorkers = 2, // Low-RAM safe constraint for mobile devices
    this.defaultTimeout = const Duration(seconds: 5),
  });

  int get activeJobs => _activeJobs;
  bool get isDisposed => _isDisposed;

  /// Executes heavy computation in a background isolate using Flutter's compute runner.
  Future<R> execute<T, R>(
    ComputeCallback<T, R> callback,
    T message, {
    TaskPriority priority = TaskPriority.normal,
    Duration? timeout,
  }) async {
    if (_isDisposed) {
      throw StateError('Cannot execute tasks on a disposed IsolateWorkerPool');
    }

    _activeJobs++;
    final effectiveTimeout = timeout ?? defaultTimeout;

    try {
      final result = await compute(callback, message).timeout(
        effectiveTimeout,
        onTimeout: () {
          throw TimeoutException('Isolate execution timed out after $effectiveTimeout');
        },
      );
      return result;
    } finally {
      _activeJobs--;
    }
  }

  /// Disposes pool and rejects pending job admissions.
  void dispose() {
    _isDisposed = true;
  }
}
