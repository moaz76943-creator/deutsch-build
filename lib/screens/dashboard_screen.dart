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
              children: <Widget>[
                // بطاقة الإحصائيات السريعة
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildStatItem('سلسلة الأيام', '🔥 نشط'),
                      _buildStatItem('الكلمات المحفوظة', '📚 المعجم'),
                      _buildStatItem('مستوى الإتقان', '⭐ تقدمك'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('الأدوات التعليمية السريعة:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // اختصارات سريعة
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: <Widget>[
<<<<<<< HEAD
                    _buildActionCard(context, 'مراجعة SRS', Icons.style_rounded, () async {
                      await srs.loadLibrary();
                      return srs.SrsFlashcardDeckScreen();
                    }),
                    _buildActionCard(context, 'التراخيص والمصادر', Icons.verified_user_rounded, () async {
                      await license.loadLibrary();
                      return license.LicenseAttributionScreen();
                    }),
                    _buildActionCard(context, 'المفكرة الشخصية', Icons.book_rounded, () async {
                      await journal.loadLibrary();
                      return journal.VocabularyJournalScreen();
                    }),
                    _buildActionCard(context, 'طوارئ السفر', Icons.local_hospital_rounded, () async {
                      await emergency.loadLibrary();
                      return emergency.EmergencyPhrasebookScreen();
                    }),
=======
                    _buildActionCard(context, 'مراجعة SRS', Icons.style_rounded,
                        const SrsFlashcardDeckScreen()),
                    _buildActionCard(
                        context,
                        'التراخيص والمصادر',
                        Icons.verified_user_rounded,
                        const LicenseAttributionScreen()),
                    _buildActionCard(context, 'المفكرة الشخصية',
                        Icons.book_rounded, const VocabularyJournalScreen()),
                    _buildActionCard(
                        context,
                        'طوارئ السفر',
                        Icons.local_hospital_rounded,
                        const EmergencyPhrasebookScreen()),
>>>>>>> origin/staging/v2-full-platform
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
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

  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, Future<Widget> Function() screenLoader) {
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
