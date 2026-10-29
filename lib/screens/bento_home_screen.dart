import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/repositories/vocabulary_repository.dart';
import 'vocabulary_journal_screen.dart';
import 'focus_quiz_screen.dart';
import 'db_health_screen.dart';
import 'mastery_mosaic_screen.dart';
import 'wellbeing_sanctuary_screen.dart';

class BentoHomeScreen extends ConsumerWidget {
  const BentoHomeScreen({super.key});

  // مجدول التدفق العصبي مع الساعة البيولوجية (Circadian Flow Scheduler)
  String getCircadianGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return 'صباح النقاء: ذهنك متقد وجاهز للاستيعاب العميق ☀️';
    } else if (hour >= 12 && hour < 18) {
      return 'مساء الاستقرار: إيقاع ثابت وتدفق معرفي هادئ 🌿';
    } else {
      return 'هدوء الليل: تثبيت عميق في الذاكرة طويلة المدى 🌙';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VocabularyRepository repo = VocabularyRepository();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deutsch بالعربي 🌿',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getCircadianGreeting(),
                          style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.assessment_rounded, color: Color(0xFF38BDF8)),
                          onPressed: () async {
                            final report = await repo.generateDiagnosticReport();
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF0F172A),
                                title: const Text('📋 التقرير التشخيصي المحلي', style: TextStyle(color: Colors.white, fontSize: 16)),
                                content: SelectableText(report, style: const TextStyle(color: Color(0xFF34D399), fontSize: 12)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إغلاق', style: TextStyle(color: Colors.white70)),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'تقرير الصحة التشخيصي',
                        ),
                        IconButton(
                          icon: const Icon(Icons.monitor_heart_rounded, color: Color(0xFF34D399)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DbHealthScreen()),
                            );
                          },
                          tooltip: 'صحة البيانات المحلية',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _BentoTile(
                        title: 'المفكرة الكونية',
                        subtitle: 'SM-2 ولغات متعددة',
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF38BDF8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VocabularyJournalScreen()),
                          );
                        },
                      ),
                      _BentoTile(
                        title: 'استوديو التركيز',
                        subtitle: 'Pomodoro وفراغات سياقية',
                        icon: Icons.psychology_rounded,
                        color: const Color(0xFF34D399),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FocusQuizScreen()),
                          );
                        },
                      ),
                      _BentoTile(
                        title: 'فسيفساء الإنجاز',
                        subtitle: 'اليقين المعرفي الهادئ',
                        icon: Icons.local_florist_rounded,
                        color: Colors.amberAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MasteryMosaicScreen()),
                          );
                        },
                      ),
                      _BentoTile(
                        title: 'مملكة الرفاهية',
                        subtitle: 'الاحتفاء الذاتي واللاتنافسية',
                        icon: Icons.spa_rounded,
                        color: const Color(0xFFF472B6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WellbeingSanctuaryScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BentoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: AppBaseGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
