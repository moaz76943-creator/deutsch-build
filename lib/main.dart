import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/fast_onboarding_screen.dart';
import 'services/crash_loop_guard.dart';
import 'services/pack_downloader_service.dart';
import 'services/user_vault_security_service.dart';

// A broken widget or a failed post-frame boot check must not leave a blank
// process. Resetting a widget tree never clears downloaded packs or the vault.
final ValueNotifier<int> _bootRetryGeneration = ValueNotifier<int>(0);

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    ErrorWidget.builder = (details) => Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('تعذّر عرض هذه الشاشة. البيانات محفوظة.'),
            TextButton(
              onPressed: () => _bootRetryGeneration.value++,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
    runApp(const ProviderScope(child: _RecoverableAppRoot()));
  }, (Object error, StackTrace stackTrace) {
    debugPrint('Uncaught Zone Error: $error\n$stackTrace');
  });
}

class _RecoverableAppRoot extends StatefulWidget {
  const _RecoverableAppRoot();

  @override
  State<_RecoverableAppRoot> createState() => _RecoverableAppRootState();
}

class _RecoverableAppRootState extends State<_RecoverableAppRoot> {
  String? _bootFailure;

  @override
  void initState() {
    super.initState();
    // Never block the first frame on disk, catalog, vault or pack integrity.
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyBoot());
  }

  Future<void> _verifyBoot() async {
    try {
      await CrashLoopGuard.verifyBootState();
      if (mounted && _bootFailure != null) {
        setState(() => _bootFailure = null);
      }
    } catch (error, stackTrace) {
      debugPrint('Deferred boot guard failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _bootFailure = 'تعذّر تهيئة التطبيق. يمكن إعادة المحاولة دون حذف البيانات.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _bootRetryGeneration,
      builder: (context, generation, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: UserVaultSecurityService.recoveryMessage,
          builder: (context, vaultFailure, _) {
            final failure = vaultFailure ?? _bootFailure;
            if (failure != null) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(failure, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                UserVaultSecurityService.clearRecoveryMessage();
                                setState(() => _bootFailure = null);
                                _bootRetryGeneration.value++;
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _verifyBoot(),
                                );
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return DeutschApp(key: ValueKey<int>(generation));
          },
        );
      },
    );
  }
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
