import '../../screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/active_language_provider.dart';
import '../../screens/flashcards_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../services/database_service.dart';

/// مسار الصفر-إلى-واحد: أسرع تجربة وصول لأول بطاقة بدون إنترنت
class FastOnboardingScreen extends ConsumerStatefulWidget {
  const FastOnboardingScreen({super.key, this.readReviewCount});

  /// Optional read seam for deterministic widget tests. Production keeps the
  /// existing learner progress database as the sole source of truth.
  final Future<int> Function()? readReviewCount;

  @override
  ConsumerState<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends ConsumerState<FastOnboardingScreen> {
  bool _routed = false;
  bool _hasError = false;
  bool _isCheckingProgress = false;
  bool _isMissingContent = false;
  bool _startNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<int> _loadReviewCount() async {
    final db = await DatabaseService.instance.progressDb;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM srs_progress');
    return (result.first['count'] as int?) ?? 0;
  }

  void _retry() {
    if (!mounted || _routed || _isCheckingProgress) return;
    setState(() {
      _hasError = false;
      _isMissingContent = false;
    });
    _checkState();
  }

  Future<void> _checkState() async {
    if (!mounted || _routed || _isCheckingProgress) return;
    _isCheckingProgress = true;
    try {
      await ref
          .read(activeLanguageProvider.notifier)
          .initialize(refreshRemoteCatalog: false);

      if (!mounted) return;

      final activeState = ref.read(activeLanguageProvider);
      if (activeState.installedCodes.isEmpty) {
        setState(() {
          _isMissingContent = true;
          _hasError = true;
        });
        return;
      }

      final count = await (widget.readReviewCount?.call() ??
              _loadReviewCount())
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
                  if (!onboardingContext.mounted || _startNavigating) return;
                  _startNavigating = true;
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      _isCheckingProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isMissingContent
                        ? 'No installed content found.'
                        : 'تعذر فتح سجل التقدّم المحلي.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: OutlinedButton(
                      onPressed: _retry,
                      child: const Text('إعادة المحاولة'),
                    ),
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
  }
}
