import '../../screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import '../../screens/flashcards_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../services/database_service.dart';

/// مسار الصفر-إلى-واحد: أسرع تجربة وصول لأول بطاقة بدون إنترنت
class FastOnboardingScreen extends StatefulWidget {
  const FastOnboardingScreen({super.key, this.readReviewCount});

  /// Optional read seam for deterministic widget tests. Production keeps the
  /// existing learner progress database as the sole source of truth.
  final Future<int> Function()? readReviewCount;

  @override
  State<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends State<FastOnboardingScreen> {
  bool _routed = false;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkState();
  }

  Future<int> _loadReviewCount() async {
    final db = await DatabaseService.instance.progressDb;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM srs_progress');
    return (result.first['count'] as int?) ?? 0;
  }

  void _retry() {
    if (!mounted || _routed) return;
    setState(() {
      _initFuture = _checkState();
    });
  }

  Future<void> _checkState() async {
    if (!mounted || _routed) return;
    final count = await (widget.readReviewCount?.call() ?? _loadReviewCount())
        .timeout(const Duration(seconds: 8));

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
                  MaterialPageRoute<void>(
                    builder: (_) => const FlashcardsScreen(),
                  ),
                );
              },
            ),
          );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'تعذر فتح سجل التقدّم المحلي.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _retry,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          backgroundColor: Color(0xFF0F172A),
          body: Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
        );
      },
    );
  }
}
