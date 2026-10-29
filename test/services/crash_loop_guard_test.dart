import 'dart:async';
import 'dart:io';

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


class FailOnceWriteLedger extends MemoryLedger {
  bool failFirstWrite = true;

  @override
  Future<void> write(Map<String, dynamic> state) async {
    if (failFirstWrite) {
      failFirstWrite = false;
      throw const FileSystemException('transient ledger write failure');
    }
    await super.write(state);
  }
}

class FailOnceReadLedger extends MemoryLedger {
  bool failFirstRead = true;

  @override
  Future<Map<String, dynamic>?> read() async {
    if (failFirstRead) {
      failFirstRead = false;
      throw const FileSystemException('transient ledger read failure');
    }
    return super.read();
  }
}

class PausedWriteLedger extends MemoryLedger {
  final entered = Completer<void>();
  final release = Completer<void>();
  bool _pauseFirstWrite = true;

  @override
  Future<void> write(Map<String, dynamic> state) async {
    if (_pauseFirstWrite) {
      _pauseFirstWrite = false;
      entered.complete();
      await release.future;
    }
    await super.write(state);
  }
}

class PausedReadLedger extends MemoryLedger {
  final entered = Completer<void>();
  final release = Completer<void>();
  bool pauseNextRead = false;

  @override
  Future<Map<String, dynamic>?> read() async {
    if (!pauseNextRead) return super.read();
    pauseNextRead = false;
    final snapshot = await super.read();
    entered.complete();
    await release.future;
    return snapshot;
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


  test('stable acknowledgement waits for an in-flight boot write', () async {
    final store = PausedWriteLedger();
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 24),
    );
    final boot = guard.beginBoot();
    await store.entered.future;
    final stable = guard.markStable();
    store.release.complete();
    await boot;
    await stable;
    expect(store.data!['clean'], isTrue);
    expect(store.data!['failures'], 0);
    expect(store.writes, 2);
  });

  test('recovery cannot be overwritten by a delayed stable write', () async {
    final store = PausedReadLedger();
    store.data = <String, dynamic>{
      'started': DateTime.utc(2026, 10, 24).millisecondsSinceEpoch,
      'clean': false,
      'failures': 1,
      'safe': true,
    };
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 24),
    );
    expect(await guard.beginBoot(), isTrue);
    store.pauseNextRead = true;
    final stable = guard.markStable();
    await store.entered.future;
    final recovery = guard.exitAfterRecovery();
    // Give the unsequenced implementation a chance to write its recovery
    // state before the older stability snapshot is released.
    await Future<void>.delayed(Duration.zero);
    store.release.complete();
    await stable;
    await recovery;
    expect(store.data!['safe'], isFalse);
    expect(store.data!['clean'], isTrue);
    expect(guard.safeModeEnabled, isFalse);
  });

  test('lifecycle stability before beginBoot does not erase crash evidence',
      () async {
    final store = MemoryLedger();
    store.data = <String, dynamic>{
      'started': 123,
      'clean': false,
      'failures': 1,
      'safe': false,
    };
    final guard = CrashLoopGuard(store: store);
    await guard.markStable();
    expect(store.writes, 0);
    expect(store.data!['clean'], isFalse);
    expect(store.data!['failures'], 1);
  });

  test('transient boot write failure permits retry without false stability',
      () async {
    final store = FailOnceWriteLedger();
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 25),
    );

    expect(await guard.beginBoot(), isTrue,
        reason: 'unreadable or unwritable boot ledger must fail closed');
    expect(guard.safeModeEnabled, isTrue);
    expect(store.data, isNull, reason: 'failed write is not a durable boot');
    await guard.markStable();
    expect(store.data, isNull,
        reason: 'failed boot must not acknowledge an earlier ledger');

    expect(await guard.beginBoot(), isFalse);
    expect(store.writes, 1);
    expect(store.data!['clean'], isFalse);
    await guard.markStable();
    expect(store.data!['clean'], isTrue);
  });

  test('transient boot read failure enters safe mode until retry', () async {
    final store = FailOnceReadLedger();
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 25),
    );

    expect(await guard.beginBoot(), isTrue,
        reason: 'missing crash evidence cannot authorize external packs');
    expect(guard.safeModeEnabled, isTrue);
    expect(store.writes, 0);
    await guard.markStable();
    expect(store.writes, 0,
        reason: 'an unrecorded boot cannot be acknowledged as stable');

    expect(await guard.beginBoot(), isFalse);
    expect(guard.safeModeEnabled, isFalse);
    expect(store.writes, 1);
    expect(store.data!['clean'], isFalse);
  });

  test('concurrent failed boot callers can retry on the same guard', () async {
    final store = FailOnceWriteLedger();
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 25),
    );
    final first = guard.beginBoot();
    final second = guard.beginBoot();
    expect(identical(first, second), isTrue);
    expect(await Future.wait(<Future<bool>>[first, second]),
        <bool>[true, true]);
    expect(store.writes, 0);

    expect(await guard.beginBoot(), isFalse);
    expect(store.writes, 1);
    expect(store.data!['clean'], isFalse);
  });


  test('ledger write does not destroy an interrupted legacy staging file',
      () async {
    final root = await Directory.systemTemp.createTemp('boot-ledger-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final legacyStage = File('${root.path}/.rapid_boot_ledger.json.new');
    await legacyStage.writeAsString('interrupted previous staging bytes');

    final store = FileBootLedgerStore(root: root);
    await store.write(<String, dynamic>{
      'started': 123,
      'clean': false,
      'failures': 0,
      'safe': false,
    });

    expect(await legacyStage.readAsString(),
        'interrupted previous staging bytes');
    expect((await store.read())?['started'], 123);
  });

  test('concurrent file ledger writes use independent temporary paths',
      () async {
    final root = await Directory.systemTemp.createTemp('boot-ledger-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final writers = List<FileBootLedgerStore>.generate(
        16, (_) => FileBootLedgerStore(root: root));
    await Future.wait(<Future<void>>[
      for (var i = 0; i < writers.length; i++)
        writers[i].write(<String, dynamic>{
          'started': i,
          'clean': false,
          'failures': 0,
          'safe': false,
        }),
    ]);

    final result = await FileBootLedgerStore(root: root).read();
    expect(result?['started'], inInclusiveRange(0, writers.length - 1));
    expect((await root.list().toList()).whereType<Directory>(), isEmpty);
  });


  test('malformed crash ledger fails closed and is preserved until recovery',
      () async {
    final root = await Directory.systemTemp.createTemp('boot-corrupt-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final ledger = File('${root.path}/.rapid_boot_ledger.json');
    const damaged = '{"started":';
    await ledger.writeAsString(damaged);
    final store = FileBootLedgerStore(root: root);
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 25),
    );

    expect(await guard.beginBoot(), isTrue);
    expect(guard.safeModeEnabled, isTrue);
    expect(await ledger.readAsString(), damaged,
        reason: 'failed boot must not overwrite crash evidence');

    // Explicit recovery (after external-pack reset) may replace this
    // non-learner ledger; ordinary startup must not.
    await guard.exitAfterRecovery();
    expect((await store.read())?['safe'], isFalse);
    expect(await guard.beginBoot(), isFalse);
    expect((await store.read())?['clean'], isFalse);
  });

  test('oversized existing ledger is not mistaken for first launch', () async {
    final root = await Directory.systemTemp.createTemp('boot-oversize-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final ledger = File('${root.path}/.rapid_boot_ledger.json');
    final oversized = List<String>.filled(2049, 'x').join();
    await ledger.writeAsString(oversized);
    final guard = CrashLoopGuard(
      store: FileBootLedgerStore(root: root),
      clock: () => DateTime.utc(2026, 10, 25),
    );

    expect(await guard.beginBoot(), isTrue);
    expect(guard.safeModeEnabled, isTrue);
    expect(await ledger.readAsString(), oversized);
  });

  test('invalid ledger field types cannot bypass sticky safe mode', () async {
    final root = await Directory.systemTemp.createTemp('boot-types-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final ledger = File('${root.path}/.rapid_boot_ledger.json');
    const invalid =
        '{"started":1792886400000,"clean":false,"failures":2,"safe":"true"}';
    await ledger.writeAsString(invalid);
    final guard = CrashLoopGuard(
      store: FileBootLedgerStore(root: root),
      clock: () => DateTime.utc(2026, 10, 25),
    );

    expect(await guard.beginBoot(), isTrue);
    expect(guard.safeModeEnabled, isTrue);
    expect(await ledger.readAsString(), invalid);
  });

  test('missing ledger remains a valid first boot', () async {
    final root = await Directory.systemTemp.createTemp('boot-missing-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final store = FileBootLedgerStore(root: root);
    final guard = CrashLoopGuard(
      store: store,
      clock: () => DateTime.utc(2026, 10, 25),
    );

    expect(await guard.beginBoot(), isFalse);
    expect((await store.read())?['safe'], isFalse);
    expect((await store.read())?['failures'], 0);
  });
}
