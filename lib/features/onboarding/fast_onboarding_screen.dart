import '../../screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import '../../screens/flashcards_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../services/database_service.dart';

/// مسار الصفر-إلى-واحد: أسرع تجربة وصول لأول بطاقة بدون إنترنت
class FastOnboardingScreen extends StatefulWidget {
  const FastOnboardingScreen({super.key});

  @override
  State<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends State<FastOnboardingScreen> {
  bool _routed = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    if (!mounted || _routed) return;
    try {
      final db = await DatabaseService.instance.progressDb;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM srs_progress');
      final count = (result.first['count'] as int?) ?? 0;

      if (!mounted || _routed) return;
      _routed = true;

      // A missing content pack must not block the first-run explanation.
      // Learners with saved review rows return to the shell.
      final Widget next = count > 0
          ? const MainShellScreen()
          : Builder(
              // This context belongs to the new onboarding route. The
              // FastOnboardingScreen state is disposed by pushReplacement.
              builder: (onboardingContext) => OnboardingScreen(
                onStart: () {
                  if (!onboardingContext.mounted) return;
                  Navigator.of(onboardingContext).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const FlashcardsScreen(),
                    ),
                  );
                },
              ),
            );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => next),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text('تعذر فتح سجل التقدّم المحلي.'),
        ),
      );
    }
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      ),
    );
  }
}
