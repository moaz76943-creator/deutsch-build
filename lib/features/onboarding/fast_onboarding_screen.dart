import '../../screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import '../../screens/flashcards_screen.dart';
<<<<<<< HEAD
import '../../screens/onboarding_screen.dart';
import '../../services/database_service.dart';
import '../../core/catalog/language_readiness_matrix.dart';
import '../../services/language_pack_manager.dart';
import '../../core/language_bidi_helper.dart';
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

/// مسار الصفر-إلى-واحد: أسرع تجربة وصول لأول بطاقة بدون إنترنت
class FastOnboardingScreen extends StatefulWidget {
  const FastOnboardingScreen({super.key});

  @override
  State<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends State<FastOnboardingScreen> {
  bool _isNavigating = false;
  bool _hasError = false;
  TextDirection _errorDirection = TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve basic direction from current context as fallback
    _errorDirection = Directionality.maybeOf(context) ?? TextDirection.rtl;
  }

  Future<void> _checkState() async {
    if (!mounted) return;
    try {
      final db = await DatabaseService.instance.progressDb;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM srs_progress');
      final count = (result.first['count'] as int?) ?? 0;

      if (!mounted) return;

      if (count > 0) {
        if (!_isNavigating) {
          _isNavigating = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShellScreen()),
          );
        }
        return;
      }

      // New user: Resolve available learning paths instead of hardcoding 'de'
      String? selectedPath;
      String? selectedPack;

      for (final bcp47Locale in LanguagePackManager.supportedBcp47Locales) {
        final langCode = bcp47Locale.split('-').first.toLowerCase();

        // Skip user language (Arabic in this case, although we should query actual UI lang ideally)
        if (langCode == 'ar') continue;

        final isReady = LanguageReadinessMatrix.isProductionReady(langCode);
        final isMounted =
            await LanguagePackManager.verifyAndMountOfflinePack(bcp47Locale);

        if (isReady && isMounted) {
          selectedPath = langCode;
          selectedPack = bcp47Locale;
          break; // Prefer the first available path (e.g. 'de-DE' since it's first)
        }
      }

      if (!mounted) return;

      if (selectedPath != null && selectedPack != null) {
        if (!_isNavigating) {
          _isNavigating = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OnboardingScreen(
                onStart: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const FlashcardsScreen()),
                  );
                },
              ),
            ),
          );
        }
      } else {
        setState(() {
          _hasError = true;
          // Dynamically set RTL/LTR based on system language or default ar-SA for error screen
          _errorDirection = LanguageBiDiHelper.getDirection('ar-SA');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorDirection = LanguageBiDiHelper.getDirection('ar-SA');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    });

    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      ),
    );
  }
}
