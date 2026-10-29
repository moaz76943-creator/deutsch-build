import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'design_system/app_theme.dart';
import 'core/bootstrap/startup_boundary.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The first frame is independent of content databases and optional services.
  runApp(const DeutschApp());
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
      title: 'DEUTSCH بالعربي',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('de'),
      ],
      home: const StartupBoundary(
        child: FastOnboardingScreen(),
      ),
    ),
    );
  }
}
