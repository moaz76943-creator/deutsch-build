import 'package:flutter/material.dart';
import 'core/bootstrap/startup_boundary.dart';
import 'features/explore/presentation/section_explorer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The first frame is independent of content databases and optional services.
  runApp(const DeutschApp());
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({Key? key}) : super(key: key);

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
