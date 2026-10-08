import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'bootstrap/production_bootstrap.dart';
import 'screens/languages_screen.dart';

Future<void> _ensureDatabaseReady() async {
  try {
    final dbDir = await getDatabasesPath();
    final targetPath = p.join(dbDir, 'de-1.0.0.sqlite');
    final file = File(targetPath);

    if (!await file.exists() || (await file.length()) < 1000000) {
      await Directory(dbDir).create(recursive: true);
      final byteData = await rootBundle.load('assets/content/packs/de/sqlite/de-1.0.0.sqlite');
      final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      await file.writeAsBytes(bytes, flush: true);
    }
  } catch (e) {
    // تجاوز الخطأ لضمان عمل الواجهة
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureDatabaseReady();
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapDeutschApp();
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
