import 'package:flutter/material.dart';
import 'screens/languages_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeutschBiArabiApp());
}

class DeutschBiArabiApp extends StatelessWidget {
  const DeutschBiArabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch بالعربي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const LanguagesScreen(),
    );
  }
}
