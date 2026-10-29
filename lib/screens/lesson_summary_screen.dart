import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class LessonSummaryScreen extends StatelessWidget {
  const LessonSummaryScreen({required this.onFinish, super.key});
  final VoidCallback onFinish;

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
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppGradients.heroSunset,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'عمل رائع ومتقن!',
                  style: AppTypography.display.copyWith(color: Colors.white, fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'أتممت مراجعة درس أدوات التعريف بنجاح',
                  style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 32),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppBaseGlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: <Widget>[
                            const Text('نقاط الخبرة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('+25 XP', style: AppTypography.title.copyWith(color: const Color(0xFF10B981), fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppBaseGlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: <Widget>[
                            const Text('الدقة والإتقان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('92%', style: AppTypography.title.copyWith(color: const Color(0xFF38BDF8), fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onFinish,
                  child: const Text('العودة للرئيسية'),
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
