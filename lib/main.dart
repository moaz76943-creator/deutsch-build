import 'package:flutter/material.dart';
import 'screens/flashcards_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deutsch بالعربي',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      // توجيه إقلاع التطبيق مباشرة لشاشة البطاقات المؤمنة
      home: const FlashcardsScreen(),
    );
  }
}
