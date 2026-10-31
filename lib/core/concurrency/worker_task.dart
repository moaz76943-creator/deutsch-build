import 'dart:async';
import 'cancellation_token.dart';

class WorkerTask<T> {
  final String taskId;
  final Future<T> Function(CancellationToken token) execute;
  final Duration timeout;

  const WorkerTask({
    required this.taskId,
    required this.execute,
    this.timeout = const Duration(seconds: 30),
  });
}
