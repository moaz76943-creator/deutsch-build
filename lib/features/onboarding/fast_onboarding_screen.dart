import '../../screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Semantics(
                    label: 'تعذر فتح سجل التقدم. يمكنك إعادة المحاولة',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'تعذر فتح سجل التقدّم المحلي.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(64, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Center(
            child: Semantics(
              label: 'جارٍ تحميل التطبيق',
              child: CircularProgressIndicator.adaptive(
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
        );
      },
    );
  }
}
