import 'package:flutter/material.dart';
import 'features/explore/presentation/section_explorer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      // التصحيح الهندسي: استخدام initialLanguage بدلاً من currentLanguage
      home: const SectionExplorerScreen(initialLanguage: 'de'),
    );
  }
}
