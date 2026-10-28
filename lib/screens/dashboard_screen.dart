import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'srs_flashcard_deck_screen.dart' deferred as srs;
import 'license_attribution_screen.dart' deferred as license;
import 'vocabulary_journal_screen.dart' deferred as journal;
import 'emergency_phrasebook_screen.dart' deferred as emergency;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم المركزية (Deutsch بالعربي)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: const <Widget>[
                // بطاقة الإحصائيات السريعة
                AppBaseGlassCard(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _StatItem(label: 'سلسلة الأيام', value: '🔥 نشط'),
                      _StatItem(label: 'الكلمات المحفوظة', value: '📚 المعجم'),
                      _StatItem(label: 'مستوى الإتقان', value: '⭐ تقدمك'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text('الأدوات التعليمية السريعة:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 12),

                // اختصارات سريعة - Grid remains non-const due to callbacks, but cards optimized
                _DashboardGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value,
            style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: <Widget>[
        _ActionCard(
          title: 'مراجعة SRS',
          icon: Icons.style_rounded,
          screenLoader: () async {
            await srs.loadLibrary();
            return srs.SrsFlashcardDeckScreen();
          },
        ),
        _ActionCard(
          title: 'التراخيص والمصادر',
          icon: Icons.verified_user_rounded,
          screenLoader: () async {
            await license.loadLibrary();
            return license.LicenseAttributionScreen();
          },
        ),
        _ActionCard(
          title: 'المفكرة الشخصية',
          icon: Icons.book_rounded,
          screenLoader: () async {
            await journal.loadLibrary();
            return journal.VocabularyJournalScreen();
          },
        ),
        _ActionCard(
          title: 'طوارئ السفر',
          icon: Icons.local_hospital_rounded,
          screenLoader: () async {
            await emergency.loadLibrary();
            return emergency.EmergencyPhrasebookScreen();
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<Widget> Function() screenLoader;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.screenLoader,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final screen = await screenLoader();
        if (context.mounted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        }
      },
      child: AppBaseGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: const Color(0xFF34D399), size: 32),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
