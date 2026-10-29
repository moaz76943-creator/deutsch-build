import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/crash_loop_guard.dart';

class MemoryLedger implements BootLedgerStore {
  Map<String,dynamic>? data;
  @override
  Future<Map<String,dynamic>?> read() async =>
      data==null?null:Map<String,dynamic>.from(data!);
  @override
  Future<void> write(Map<String,dynamic> state) async {
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
}
