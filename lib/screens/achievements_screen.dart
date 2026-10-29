import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> badges = [
      {
        "title": "محترف المفردات",
        "desc": "أتممت حفظ أكثر من 500 كلمة بنجاح",
        "icon": "🏆",
        "unlocked": true
      },
      {
        "title": "سفير الاستمرارية",
        "desc": "حافظت على سلسلة تعلم لمدة 30 يوماً متواصلاً",
        "icon": "🔥",
        "unlocked": true
      },
      {
        "title": "خبير السيناريوهات",
        "desc": "أكملت جميع سيناريوهات الحياة اليومية",
        "icon": "☕",
        "unlocked": false
      },
      {
        "title": "ملك تحدي السرعة",
        "desc": "حققت المركز الأول في اختبار الـ 60 ثانية",
        "icon": "⚡",
        "unlocked": false
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('دروع الإنجازات والمكافآت'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final bool unlocked = badge['unlocked'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: unlocked
                                ? const Color(0xFF34D399)
                                    .withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge['icon']!,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                badge['title']!,
                                style: AppTypography.display.copyWith(
                                  color:
                                      unlocked ? Colors.white : Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                badge['desc']!,
                                style: AppTypography.body.copyWith(
                                  color: unlocked
                                      ? Colors.white70
                                      : Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          unlocked
                              ? Icons.check_circle_rounded
                              : Icons.lock_rounded,
                          color: unlocked
                              ? const Color(0xFF34D399)
                              : Colors.white38,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
