import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class BootLedgerStore {
  Future<Map<String,dynamic>?> read();
  Future<void> write(Map<String,dynamic> state);
}
class FileBootLedgerStore implements BootLedgerStore {
  FileBootLedgerStore({Directory? root}):_root=root;
  final Directory? _root;
  Future<File> _file() async {
    final dir=_root ?? await getApplicationSupportDirectory();
    await dir.create(recursive:true);
    return File(p.join(dir.path,'.rapid_boot_ledger.json'));
  }
  @override
  Future<Map<String,dynamic>?> read() async {
    final file=await _file();
    if(!await file.exists() || await file.length()>2048) return null;
    try {
      final value=jsonDecode(await file.readAsString());
      return value is Map?Map<String,dynamic>.from(value):null;
    } on FormatException {return null;}
  }
  @override
  Future<void> write(Map<String,dynamic> state) async {
    final file=await _file();
    final tmp=File(file.path+'.new');
    await tmp.writeAsString(jsonEncode(state),flush:true);
    await tmp.rename(file.path);
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

  CrashLoopGuard({BootLedgerStore? store,DateTime Function()? clock})
      : _store=store ?? FileBootLedgerStore(), _clock=clock ?? DateTime.now;
  static final CrashLoopGuard instance=CrashLoopGuard();
  final BootLedgerStore _store;
  final DateTime Function() _clock;
  bool _safe=false;
  bool get safeModeEnabled=>_safe;
  Future<bool> beginBoot() async {
    try {
      final old=await _store.read() ?? <String,dynamic>{};
      final now=_clock().toUtc().millisecondsSinceEpoch;
      final previous=old['started'];
      final rapid=previous is int && now>=previous && now-previous<=5000;
      final failures=rapid && old['clean']!=true
          ? ((old['failures'] is int ? old['failures'] as int : 0)+1).clamp(0,2)
          : 0;
      _safe=old['safe']==true || failures>=2;
      await _store.write(<String,dynamic>{
        'started':now,'clean':false,'failures':failures,'safe':_safe,
      });
    } on FileSystemException {
      // Do not introduce a new boot-blocking error on storage failures.
    }
    return _safe;
  }
  Future<void> markStable() async {
    try {
      final old=await _store.read();
      if(old!=null) await _store.write(<String,dynamic>{
        ...old,'clean':true,'failures':0,
      });
    } on FileSystemException { }
  }
  Future<void> exitAfterRecovery() async {
    final old=await _store.read() ?? <String,dynamic>{};
    await _store.write(<String,dynamic>{
      ...old,'clean':true,'failures':0,'safe':false,
    });
    _safe=false;
  }
}

class SafeModeRecoveryGate extends StatefulWidget {
  const SafeModeRecoveryGate({super.key,required this.guard,
      required this.resetPacks,required this.child});
  final CrashLoopGuard guard;
  final Future<void> Function() resetPacks;
  final Widget child;
  @override
  State<SafeModeRecoveryGate> createState()=>_SafeModeRecoveryGateState();
}
class _SafeModeRecoveryGateState extends State<SafeModeRecoveryGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!mounted)return;
      // A full file-ledger check happens only after the visible first frame.
      await widget.guard.beginBoot();
      if(!mounted)return;
      if(widget.guard.safeModeEnabled) _dialog();
      Future<void>.delayed(const Duration(seconds:6),(){
        if(mounted) widget.guard.markStable();
      });
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state==AppLifecycleState.detached) widget.guard.markStable();
  }
  Future<void> _dialog() async {
    await showDialog<void>(context:context,barrierDismissible:false,
      builder:(ctx)=>AlertDialog(
        title:const Text('Recovery safe mode'),
        content:const Text('Two rapid unsuccessful launches detected. '
            'External packs are disabled; personal learning data is kept.'),
        actions:<Widget>[
          TextButton(onPressed:()=>Navigator.pop(ctx),
              child:const Text('Continue safely')),
          TextButton(onPressed:() async {
            try {
              await widget.resetPacks();
              await widget.guard.exitAfterRecovery();
              if(ctx.mounted) Navigator.pop(ctx);
            } catch (_) {
              if(ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content:Text('Reset failed; safe mode remains active.')));
            }
          },child:const Text('Reset external packs')),
        ],
      ));
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  Widget build(BuildContext context)=>widget.child;
}
