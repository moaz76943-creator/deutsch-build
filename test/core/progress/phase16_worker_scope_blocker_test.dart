import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 16 cannot claim worker SRS until core worker exposes a job type', () {
    final contract = File(
      'lib/core/worker/worker_contract.dart',
    ).readAsStringSync();
    final worker = File(
      'lib/core/worker/persistent_cpu_worker.dart',
    ).readAsStringSync();

    expect(contract, isNot(contains("srs.schedule")));
    expect(worker, isNot(contains("case WorkerJobTypes.srs")));
    expect(worker, contains("case WorkerJobTypes.fuzzyRank"));
  });
}
