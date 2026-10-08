import '../features/cefr_readiness_screen.dart';
import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';
import '../features/smart_notebook_screen.dart';
import '../features/smart_study_timer.dart';
import '../features/learning_analytics_screen.dart';
import '../features/verb_conjugator_screen.dart';
import '../features/unified_learning_session.dart';
import '../features/cloze_exercise_screen.dart';
import '../features/listening_ladder_screen.dart';
import '../features/branching_dialogues_screen.dart';
import '../features/grammar_microscopy_screen.dart';
import '../features/sentence_transformer_screen.dart';
import '../features/universal_search_engine.dart';
import 'privacy_dashboard_screen.dart';

class HomeHubScreen extends StatelessWidget {
  const HomeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Guten Morgen 👋', style: AppStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UniversalSearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyDashboardScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LearningAnalyticsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('مستواك الحالي: B1', style: AppStyles.subtitle),
              const SizedBox(height: 20),
              
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('أكمل جلستك اليومية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('8 دقائق', style: AppStyles.subtitle.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: 0.72,
                      backgroundColor: Colors.grey.shade200,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: 'ابدأ الجلسة التكيفية الآن',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UnifiedLearningSession(
                                tasks: [
                                  LearningTask(
                                    id: 'task_1',
                                    prompt: 'أنا أساعد الرجل (helfen + Dativ)',
                                    correctAnswer: 'Ich helfe dem Mann',
                                    explanation: 'الفعل helfen يأخذ دائماً حالة Dativ، لذا تصبح الأداة dem.',
                                    grammarPattern: 'Dativ after helfen',
                                  ),
                                  LearningTask(
                                    id: 'task_2',
                                    prompt: 'أنا أذهب إلى المنزل',
                                    correctAnswer: 'Ich gehe nach Hause',
                                    explanation: 'تعبير ثابت للاتجاه إلى البيت: nach Hause.',
                                    grammarPattern: 'Fixed Preposition Phrase',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              const Text('مسارات ومختبرات التعلم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _buildTile(context, 'مجهر القواعد', Icons.biotech_rounded, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrammarMicroscopyScreen()))),
                  _buildTile(context, 'سلّم الاستماع', Icons.hearing_rounded, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListeningLadderScreen()))),
                  _buildTile(context, 'محادثات متفرعة', Icons.alt_route_rounded, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BranchingDialoguesScreen()))),
                  _buildTile(context, 'إكمال الفراغ', Icons.edit_note_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClozeExerciseScreen()))),
                  _buildTile(context, 'محوّل الجمل', Icons.transform_rounded, Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SentenceTransformerScreen()))),
                  _buildTile(context, 'تصريف الأفعال', Icons.bolt_rounded, AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerbConjugatorScreen()))),
                  _buildTile(context, 'جاهزية B1', Icons.assessment_outlined, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CefrReadinessScreen()))),
                  _buildTile(context, 'دفتر الملاحظات', Icons.note_alt_rounded, Colors.deepPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartNotebookScreen()))),
                  _buildTile(context, 'مؤقت التركيز', Icons.timer_rounded, AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartStudyTimerScreen()))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            radius: 22,
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
