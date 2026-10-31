import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class BootLedgerStore {
  Future<Map<String, dynamic>?> read();
  Future<void> write(Map<String, dynamic> state);
}

class FileBootLedgerStore implements BootLedgerStore {
  FileBootLedgerStore({Directory? root}) : _root = root;
  final Directory? _root;
  Future<File> _file() async {
    final dir = _root ?? await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    return File(p.join(dir.path, '.rapid_boot_ledger.json'));
  }

  @override
  Future<Map<String, dynamic>?> read() async {
    final file = await _file();
    // A missing ledger is a first launch. A present but damaged ledger is
    // NOT a first launch: treating it as null silently disables safe mode.
    if (!await file.exists()) return null;
    try {
      if (await file.length() > 2048) {
        throw FileSystemException('Boot ledger exceeds size limit', file.path);
      }
      final value = jsonDecode(await file.readAsString());
      if (value is! Map<String, dynamic>) {
        throw FileSystemException('Malformed boot ledger', file.path);
      }
      final started = value['started'];
      final failures = value['failures'];
      if (started is! int ||
          started < 0 ||
          failures is! int ||
          failures < 0 ||
          failures > 2 ||
          value['clean'] is! bool ||
          value['safe'] is! bool) {
        throw FileSystemException('Invalid boot ledger fields', file.path);
      }
      return Map<String, dynamic>.from(value);
    } on FormatException {
      throw FileSystemException('Malformed boot ledger', file.path);
    }
  }

  @override
  Future<void> write(Map<String, dynamic> state) async {
    final file = await _file();
    // Each writer must own its staging path. A shared .new file can be
    // truncated or renamed by a concurrent writer, losing the boot ledger.
    final stagingDirectory =
        await file.parent.createTemp('.rapid_boot_ledger-');
    try {
      final staged = File(p.join(stagingDirectory.path, 'ledger.json'));
      await staged.writeAsString(jsonEncode(state), flush: true);
      await staged.rename(file.path);
    } finally {
      try {
        if (await stagingDirectory.exists()) {
          await stagingDirectory.delete(recursive: true);
        }
      } on FileSystemException {
        // Cleanup failure cannot invalidate an already committed ledger.
      }
    }
  }
}

/// Two consecutive rapid, unclean launches trigger safe mode on the third.
/// Boot-to-boot timing is a conservative proxy for the unavailable crash time.
class CrashLoopGuard {
  static Stopwatch? _startupClock;
  static bool previousBootWasInterrupted = false;

  /// Fast preference-only entry gate. Full recovery-ledger IO runs after the
  /// first frame through SafeModeRecoveryGate.
  static Future<void> verifyBootState() async {
    _startupClock ??= Stopwatch()..start();
    try {
      final preferences = await SharedPreferences.getInstance();
      previousBootWasInterrupted =
          preferences.getBool('boot.pending.v1') ?? false;
    } catch (_) {
      previousBootWasInterrupted = false;
    }
  }

  static Future<void> waitForIntegrityWindow() async {
    final clock = _startupClock;
    if (clock == null) return;
    const minimum = Duration(seconds: 3);
    final remaining = minimum - clock.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
  }

  CrashLoopGuard({BootLedgerStore? store, DateTime Function()? clock})
      : _store = store ?? FileBootLedgerStore(),
        _clock = clock ?? DateTime.now;
  static final CrashLoopGuard instance = CrashLoopGuard();
  final BootLedgerStore _store;
  final DateTime Function() _clock;
  bool _safe = false;
  // A failed filesystem write is not a recorded launch. Do not acknowledge it.
  bool _bootLedgerRecorded = false;
  Future<bool>? _beginBootFuture;
  // Serialize ledger transitions: a delayed boot write must not overwrite a
  // later stability or recovery acknowledgement.
  Future<void> _ledgerTail = Future<void>.value();

  Future<T> _serializeLedger<T>(Future<T> Function() action) {
    final result = _ledgerTail.then((_) => action());
    // A failed operation must not permanently poison later recovery writes.
    _ledgerTail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  bool get safeModeEnabled => _safe;

  // A retry or a second startup boundary in the same process must not be
  // counted as another failed Android launch. Cache the in-flight result too,
  // so simultaneous callers perform exactly one ledger transition.
  Future<bool> beginBoot() {
    final cached = _beginBootFuture;
    if (cached != null) return cached;

    late final Future<bool> attempt;
    attempt = _serializeLedger(_beginBootOnce).then(
      (value) => value,
      onError: (Object error, StackTrace stack) {
        // A transient filesystem outage must not permanently memoize an
        // unrecorded launch. Concurrent callers still share this attempt.
        if (identical(_beginBootFuture, attempt)) {
          _beginBootFuture = null;
        }
        if (error is FileSystemException) {
          // An unreadable or unwritable crash ledger cannot establish that
          // external content is safe to activate. Fail closed for this
          // attempt, but allow a fresh retry once storage recovers.
          _safe = true;
          return true;
        }
        Error.throwWithStackTrace(error, stack);
      },
    );
    _beginBootFuture = attempt;
    return attempt;
  }

  Future<bool> _beginBootOnce() async {
    _bootLedgerRecorded = false;
    final old = await _store.read() ?? <String, dynamic>{};
      final now = _clock().toUtc().millisecondsSinceEpoch;
      final previous = old['started'];
      final rapid =
          previous is int && now >= previous && now - previous <= 5000;
      final failures = rapid && old['clean'] != true
          ? ((old['failures'] is int ? old['failures'] as int : 0) + 1)
              .clamp(0, 2)
          : 0;
      _safe = old['safe'] == true || failures >= 2;
      await _store.write(<String, dynamic>{
        'started': now,
        'clean': false,
        'failures': failures,
        'safe': _safe,
      });
    _bootLedgerRecorded = true;
    return _safe;
  }

  Future<void> markStable() {
    // A lifecycle event before beginBoot must never acknowledge a previous
    // process's unfinished launch as healthy.
    if (_beginBootFuture == null) return Future<void>.value();
    return _serializeLedger(() async {
      // beginBoot may have failed to persist while this ACK was queued.
      if (!_bootLedgerRecorded) return;
      try {
        final old = await _store.read();
        if (old != null) {
          await _store.write(<String, dynamic>{
            ...old,
            'clean': true,
            'failures': 0,
          });
        }
      } on FileSystemException {}
    });
  }

  Future<void> exitAfterRecovery() => _serializeLedger(() async {
        // Explicit recovery follows a successful external-pack reset. A
        // corrupted crash ledger must not permanently trap the user in SAFE.
        // A genuine write failure still leaves SAFE enabled.
        Map<String, dynamic> old;
        try {
          old = await _store.read() ?? <String, dynamic>{};
        } on FileSystemException {
          old = <String, dynamic>{};
        }
        await _store.write(<String, dynamic>{
          ...old,
          'started': old['started'] is int
              ? old['started']
              : _clock().toUtc().millisecondsSinceEpoch,
          'clean': true,
          'failures': 0,
          'safe': false,
        });
        _safe = false;
        _bootLedgerRecorded = false;
        // Only re-arm after the successful durable recovery write. Pending
        // stability writes cannot restore an older sticky-safe snapshot.
        _beginBootFuture = null;
      });
}

class SafeModeRecoveryGate extends StatefulWidget {
  const SafeModeRecoveryGate(
      {super.key,
      required this.guard,
      required this.resetPacks,
      required this.child});
  final CrashLoopGuard guard;
  final Future<void> Function() resetPacks;
  final Widget child;
  @override
  State<SafeModeRecoveryGate> createState() => _SafeModeRecoveryGateState();
}

class _SafeModeRecoveryGateState extends State<SafeModeRecoveryGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // A full file-ledger check happens only after the visible first frame.
      await widget.guard.beginBoot();
      if (!mounted) return;
      if (widget.guard.safeModeEnabled) _dialog();
      Future<void>.delayed(const Duration(seconds: 6), () {
        if (mounted) widget.guard.markStable();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) widget.guard.markStable();
  }

  Future<void> _dialog() async {
    await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: const Text('Recovery safe mode'),
              content: const Text('Two rapid unsuccessful launches detected. '
                  'External packs are disabled; personal learning data is kept.'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Continue safely')),
                TextButton(
                    onPressed: () async {
                      try {
                        await widget.resetPacks();
                        await widget.guard.exitAfterRecovery();
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (_) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                              content: Text(
                                  'Reset failed; safe mode remains active.')));
                        }
                      }
                    },
                    child: const Text('Reset external packs')),
              ],
            ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
