import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/fast_onboarding_screen.dart';
import 'services/crash_loop_guard.dart';
import 'services/pack_downloader_service.dart';

void main() {
  runZonedGuarded<void>(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const ProviderScope(child: DeutschApp()));

    // Keep disk-backed boot checks off the first-frame critical path.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(CrashLoopGuard.verifyBootState());
    });
  }, (Object error, StackTrace stackTrace) {
    debugPrint('Uncaught Zone Error: $error\n$stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deutsch بالعربي',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
      ),
      // نقطة الانطلاق إلى شاشة البداية الكاملة لتطبيقك
      home: SafeModeRecoveryGate(
        guard:CrashLoopGuard.instance,
        resetPacks:() async {
          final installed=await PackDownloaderService.getInstalledPacks();
          for(final item in installed) {
            final code=item['languageCode'];
            if(code is String && code!='de') {
              if(!await PackDownloaderService.deletePack(code)) {
                throw StateError('External pack reset failed');
              }
            }
          }
        },
        child:const FastOnboardingScreen(),
      ),
    );
  }
}

/// Backwards-compatible app root for existing launch and smoke tests.
class DeutschApp extends MyApp {
  const DeutschApp({super.key});
}
