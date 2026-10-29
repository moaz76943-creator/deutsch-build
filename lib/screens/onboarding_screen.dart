
import '../design_system/design_system.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({required this.onStart, super.key});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: <Widget>[
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppGradients.heroSunset,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.school_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 28),
                Text(
                  'Deutsch بالعربي',
                  style: AppTypography.display.copyWith(color: Colors.white, fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'طريقك المتقن لتعلم الألمانية بأسلوب تفاعلي وتكرار متباعد، وبدون الحاجة لإنترنت.',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                AppBaseGlassCard(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.offline_bolt_rounded, color: Color(0xFF10B981), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'دروس ومفردات مخزنة محلياً بالكامل',
                              style: AppTypography.title.copyWith(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF39C6B), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'نظام تدريب ذكي للمراجعة والحفظ الدائم',
                              style: AppTypography.title.copyWith(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: onStart,
                  child: const Text('ابدأ التعلم الآن'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
