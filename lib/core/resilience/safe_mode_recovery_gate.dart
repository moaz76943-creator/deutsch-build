import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/app_theme.dart';

/// Safe mode UI to prevent data leaks or further corruption during recovery.
class SafeModeRecoveryGate extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const SafeModeRecoveryGate({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_rounded, size: 64, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                const Text('Safe Mode', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message ?? 'Repeated startup failures detected. Data is protected.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry / Clear errors', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
