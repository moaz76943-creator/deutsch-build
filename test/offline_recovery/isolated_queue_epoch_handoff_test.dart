import 'dart:async';

import 'package:deutsch_bilarabi/core/concurrency/isolated_task_queue.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the live core queue rather than a fake. A newly active session must
/// never lose its queued work because an older in-flight task finished later.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new session task survives old in-flight completion', () async {
    final queue = IsolatedTaskQueue();
    final releaseOld = Completer<void>();

    final oldResult = queue.enqueue<String>(
      id: 'old-epoch-work',
      currentEpoch: 1,
      priority: TaskPriority.normal,
      action: () async {
        await releaseOld.future;
        return 'old';
      },
    );

    // The old task is already executing. A language/session transition occurs.
    queue.cancelStaleTasks(2);
    final freshResult = queue.enqueue<String>(
      id: 'new-epoch-work',
      currentEpoch: 2,
      priority: TaskPriority.high,
      action: () async => 'new',
    );

    releaseOld.complete();
    await oldResult.timeout(const Duration(seconds: 2));
    final actual = await freshResult.timeout(const Duration(seconds: 2));

    // Expected RED on current staging:
    // _processNext captured activeEpoch=1 from the old task and recursively
    // reuses 1, causing the new epoch=2 task to complete with null instead.
    expect(actual, 'new');
  });

  test('stale queued task is cancelled without running action', () async {
    final queue = IsolatedTaskQueue();
    final releaseOld = Completer<void>();
    final first = queue.enqueue<String>(
      id: 'running',
      currentEpoch: 1,
      priority: TaskPriority.normal,
      action: () async {
        await releaseOld.future;
        return 'running';
      },
    );
    var staleRan = false;
    final stale = queue.enqueue<String>(
      id: 'queued-stale',
      currentEpoch: 1,
      priority: TaskPriority.low,
      action: () async {
        staleRan = true;
        return 'not-allowed';
      },
    );
    queue.cancelStaleTasks(2);
    expect(await stale.timeout(const Duration(seconds: 2)), isNull);
    expect(staleRan, isFalse);
    releaseOld.complete();
    await first.timeout(const Duration(seconds: 2));
    expect(staleRan, isFalse);
  });
}
