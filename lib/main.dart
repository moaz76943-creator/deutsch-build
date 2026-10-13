import 'package:flutter/material.dart';
import 'core/bootstrap/startup_boundary.dart';
import 'core/l1_cache.dart';
import 'core/worker/persistent_cpu_worker.dart';
import 'features/explore/presentation/section_explorer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Preserve the staging startup contract: first frame before disk I/O,
  // bounded startup, existing safe mode and canonical offline content gate.
  runApp(const DeutschApp());
}

class DeutschApp extends StatefulWidget {
  const DeutschApp({super.key});
  @override
  State<DeutschApp> createState() => _DeutschAppState();
}

class _DeutschAppState extends State<DeutschApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    L1VocabularyCache().onMemoryPressure();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Do not restore or replay pending writes when resuming.
    // UI-independent CPU responses from an old session are invalidated.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      PersistentCpuWorker.instance.cancelCurrentGeneration();
      L1VocabularyCache().onMemoryPressure();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEUTSCH بالعربي',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const StartupBoundary(
        child: SectionExplorerScreen(initialLanguage: 'de'),
      ),
    );
  }
}
