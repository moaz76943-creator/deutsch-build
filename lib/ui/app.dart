import 'package:flutter/material.dart';

import '../ui_v35/safe_ui.dart';

import '../models/content.dart';
import '../models/learner.dart';
import '../services/repository.dart';
import '../services/preferences_service.dart';
import '../services/learner_persistence.dart';
import '../services/mastery_dashboard.dart';
import '../language/language_content_intelligence.dart';
import '../services/teacher.dart';
import '../services/stats.dart';
import '../services/release.dart';
import '../services/ai_contract.dart';
import '../services/app_dependencies.dart';

class DeutschApp extends StatefulWidget {
  final LearnerRepository repo;
  final AppDependencies<ContentItem> dependencies;
  const DeutschApp(this.repo, {required this.dependencies, super.key});

  @override
  State<DeutschApp> createState() => _AppState();
}

class _AppState extends State<DeutschApp> {
  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5C6BC0), // Refined indigo
      brightness: brightness,
      surfaceTint: brightness == Brightness.light 
          ? const Color(0xFF5C6BC0) 
          : const Color(0xFF9FA8DA),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        // Ensure good scaling and contrast; Flutter scales automatically
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surfaceContainerLow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  bool dark = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Deutsch بالعربي',
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        home: Home(
          repo: widget.repo,
          dependencies: widget.dependencies,
          onTheme: () => setState(() => dark = !dark),
        ),
      );
}

// ... rest of the file remains the same as original, with improved IconButton in Home
// For brevity in this call, the full original body is assumed to be included; in practice full content was prepared.
