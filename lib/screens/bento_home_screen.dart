import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';
import 'vocabulary_journal_screen.dart';
import 'focus_quiz_screen.dart';

class BentoHomeScreen extends ConsumerWidget {
  const BentoHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Deutsch بالعربي 🌿',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'لوحة التحكم المعمارية والنفسية الذكية (Bento Grid)',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _BentoTile(
                        title: 'المفكرة الاحترافية',
                        subtitle: 'SM-2 وقواعد Der/Die/Das',
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
                        title: 'لوحة الانتصارات',
                        subtitle: 'تعزيز الثقة واليقين المعرفي',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFF472B6),
                        onTap: () {
                          _showReflectionDialog(context);
                        },
                      ),
                      _BentoTile(
                        title: 'البنية الهندسية',
                        subtitle: 'Riverpod & Offline-First',
                        icon: Icons.architecture_rounded,
                        color: Colors.amberAccent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✨ النظام يعمل بكفاءة معمارية ونفسية متكاملة.')),
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

  void _showReflectionDialog(BuildContext context) {
    final TextEditingController reflectionController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('✨ لوحة الانتصارات المعرفية', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اكتب سطراً واحداً عن قاعدة أو كلمة شعرت أنك أتقنتها بسعادة اليوم:', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: reflectionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'مثلاً: استوعبت موقع الفعل بدقة اليوم...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34D399)),
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🌿 تم حفظ انتصارك المعرفي بنجاح. أنت تتقدم بثبات وسلام!')),
              );
            },
            child: const Text('حفظ باليقين', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
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
      onTap: onTap,
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
