import 'package:deutsch_bilarabi/services/crash_loop_guard.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryBootLedgerStore implements BootLedgerStore {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> read() async =>
      data == null ? null : Map<String, dynamic>.from(data!);

  @override
  Future<void> write(Map<String, dynamic> state) async {
    data = Map<String, dynamic>.from(state);
  }
}

void main() {
  test(
    'three rapid interrupted cold boots activate existing safe-mode guard',
    () async {
      final storage = MemoryBootLedgerStore();
      var now = DateTime.utc(2026, 10, 13, 0, 0, 0);
      var guard = CrashLoopGuard(store: storage, clock: () => now);

      expect(await guard.beginBoot(), false);
      now = now.add(const Duration(seconds: 1));
      // A new process owns a new guard but reads the persisted boot ledger.
      guard = CrashLoopGuard(store: storage, clock: () => now);
      expect(await guard.beginBoot(), false);
      now = now.add(const Duration(seconds: 1));
      guard = CrashLoopGuard(store: storage, clock: () => now);
      expect(await guard.beginBoot(), true);

      await guard.markStable();
      expect(storage.data?['safe'], true);
      await guard.exitAfterRecovery();
      expect(storage.data?['safe'], false);
      expect(storage.data?['failures'], 0);
    },
  );

  test('successful degraded boot does not create a false crash loop', () async {
    final storage = MemoryBootLedgerStore();
    var now = DateTime.utc(2026, 10, 13, 0, 0, 0);
    final guard = CrashLoopGuard(store: storage, clock: () => now);

    expect(await guard.beginBoot(), false);
    // Optional content failure is still a fully handled, stable boot.
    await guard.markStable();
    now = now.add(const Duration(seconds: 1));
    final restarted = CrashLoopGuard(store: storage, clock: () => now);
    expect(await restarted.beginBoot(), false);
    expect(restarted.safeModeEnabled, false);
    expect(storage.data?['failures'], 0);
  });
}
