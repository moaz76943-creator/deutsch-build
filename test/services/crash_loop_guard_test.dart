import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/crash_loop_guard.dart';

class MemoryLedger implements BootLedgerStore {
  Map<String,dynamic>? data;
  int writes = 0;
  @override
  Future<Map<String,dynamic>?> read() async =>
      data==null?null:Map<String,dynamic>.from(data!);
  @override
  Future<void> write(Map<String,dynamic> state) async {
    writes++;
    data=Map<String,dynamic>.from(state);
  }
}
void main() {
  test('two consecutive rapid unclean boots trigger safe mode',() async {
    final store=MemoryLedger();
    var now=DateTime.utc(2026,10,11);
    Future<bool> boot() => CrashLoopGuard(
        store:store,clock:()=>now).beginBoot();
    expect(await boot(),false);
    now=now.add(const Duration(seconds:2));
    expect(await boot(),false);
    now=now.add(const Duration(seconds:2));
    expect(await boot(),true);
  });
  test('completed startup and long gap reset crash counter',() async {
    final store=MemoryLedger();
    var now=DateTime.utc(2026,10,11);
    final g=CrashLoopGuard(store:store,clock:()=>now);
    await g.beginBoot();
    await g.markStable();
    now=now.add(const Duration(seconds:2));
    expect(await CrashLoopGuard(store:store,clock:()=>now).beginBoot(),false);
    now=now.add(const Duration(seconds:20));
    expect(await CrashLoopGuard(store:store,clock:()=>now).beginBoot(),false);
  });
  test('explicit recovery clears sticky safe mode without deleting data',() async {
    final store=MemoryLedger();
    var now=DateTime.utc(2026,10,11);
    late CrashLoopGuard g;
    for(var i=0;i<3;i++){
      g=CrashLoopGuard(store:store,clock:()=>now);
      await g.beginBoot();
      now=now.add(const Duration(seconds:1));
    }
    expect(g.safeModeEnabled,true);
    await g.exitAfterRecovery();
    expect(store.data?['safe'],false);
  });
  test('same process boot retry does not increment the crash counter', () async {
    final store = MemoryLedger();
    var now = DateTime.utc(2026, 10, 24);
    final guard = CrashLoopGuard(store: store, clock: () => now);
    expect(await guard.beginBoot(), isFalse);
    final originalStarted = store.data!['started'];

    now = now.add(const Duration(seconds: 1));
    expect(await guard.beginBoot(), isFalse);
    expect(store.writes, 1);
    expect(store.data!['started'], originalStarted);
    expect(store.data!['failures'], 0);

    // A new guard represents a new process launch, not a UI retry.
    expect(
      await CrashLoopGuard(store: store, clock: () => now).beginBoot(),
      isFalse,
    );
    expect(store.data!['failures'], 1);
  });

  test('parallel callers share a single boot ledger transition', () async {
    final store = MemoryLedger();
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 24),
    );
    final first = guard.beginBoot();
    final second = guard.beginBoot();
    expect(identical(first, second), isTrue);
    expect(await Future.wait(<Future<bool>>[first, second]),
        <bool>[false, false]);
    expect(store.writes, 1);
  });

  test('explicit recovery re-arms the same guard without sticky safe mode',
      () async {
    final store = MemoryLedger();
    var now = DateTime.utc(2026, 10, 24);
    CrashLoopGuard? guard;
    for (var i = 0; i < 3; i++) {
      guard = CrashLoopGuard(store: store, clock: () => now);
      await guard.beginBoot();
      now = now.add(const Duration(seconds: 1));
    }
    final recoveredGuard = guard!;
    expect(recoveredGuard.safeModeEnabled, isTrue);
    await recoveredGuard.exitAfterRecovery();
    expect(recoveredGuard.safeModeEnabled, isFalse);
    expect(await recoveredGuard.beginBoot(), isFalse);
    expect(store.data!['safe'], isFalse);
    expect(store.data!['failures'], 0);
  });

}
