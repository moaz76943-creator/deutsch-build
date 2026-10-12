import 'package:flutter/material.dart';
import 'features/explore/presentation/section_explorer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LanguageMatrixApp());
}

class LanguageMatrixApp extends StatelessWidget {
  const LanguageMatrixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محرك اللغات والتمارين',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const SectionExplorerScreen(currentLanguage: 'ar'),
    );
  }
}
