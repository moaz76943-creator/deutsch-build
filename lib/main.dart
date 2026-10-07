import 'package:flutter/material.dart';
import 'screens/languages_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deutsch بالعربي',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LanguagesScreen(),
    );
  }
}
