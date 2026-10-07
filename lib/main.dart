import 'package:flutter/material.dart';
import 'content/content_initializer.dart';
import 'content/language_selector_screen.dart';

void main() {
  ContentInitializer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch Bilarabi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deutsch Bilarabi Post-V1')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Deutsch Bilarabi Post-V1',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectorScreen(),
                  ),
                );
              },
              child: const Text('Open Language Selector'),
            ),
          ],
        ),
      ),
    );
  }
}
