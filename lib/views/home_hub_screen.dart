import 'package:flutter/material.dart';
import '../features/audio_study_player.dart';
import '../features/instant_quiz_engine.dart';
import '../features/smart_word_search.dart';
import '../features/smart_notebook_screen.dart';
import '../features/smart_study_timer.dart';
import '../features/interactive_flashcards_screen.dart';
import '../features/sentence_scramble_screen.dart';
import '../features/learning_analytics_screen.dart';
import '../features/verb_conjugator_screen.dart';
import '../features/interactive_dialogues_screen.dart';

class HomeHubScreen extends StatelessWidget {
  const HomeHubScreen({super.key});

  static const List<Map<String, String>> sampleWords = [
    {'german': 'das Haus', 'arabic': 'المنزل'},
    {'german': 'das Buch', 'arabic': 'الكتاب'},
    {'german': 'die Sonne', 'arabic': 'الشمس'},
    {'german': 'der Mond', 'arabic': 'القمر'},
    {'german': 'der Apfel', 'arabic': 'التفاحة'},
    {'german': 'das Wasser', 'arabic': 'الماء'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deutsch بالعربي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LearningAnalyticsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            _buildHubTile(
              context: context,
              title: 'دفتر الملاحظات',
              subtitle: 'تنظيم المفردات بالألوان',
              icon: Icons.note_alt_rounded,
              color: Colors.blueAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartNotebookScreen())),
            ),
            _buildHubTile(
              context: context,
              title: 'مؤقّت التركيز',
              subtitle: 'بومودورو وجولات دراسية',
              icon: Icons.timer_rounded,
              color: Colors.redAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartStudyTimerScreen())),
            ),
            _buildHubTile(
              context: context,
              title: 'المشغل الصوتي',
              subtitle: 'حفظ واستماع تكراري',
              icon: Icons.headphones_rounded,
              color: Colors.teal,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AudioStudyPlayer(words: sampleWords))),
            ),
            _buildHubTile(
              context: context,
              title: 'البطاقات الذكية',
              subtitle: 'نظام التكرار المتباعد',
              icon: Icons.style_rounded,
              color: Colors.deepPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InteractiveFlashcardsScreen(
                    cards: sampleWords.map((w) => FlashcardItem(
                      id: w['german']!,
                      frontText: w['german']!,
                      backText: w['arabic']!,
                      example: '',
                    )).toList(),
                  ),
                ),
              ),
            ),
            _buildHubTile(
              context: context,
              title: 'محادثات واقعية',
              subtitle: 'محاكاة نطق وحوارات',
              icon: Icons.forum_rounded,
              color: Colors.pinkAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InteractiveDialoguesScreen())),
            ),
            _buildHubTile(
              context: context,
              title: 'اختبار فوري',
              subtitle: 'كويز متعدد الخيارات',
              icon: Icons.quiz_rounded,
              color: Colors.amber.shade800,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstantQuizScreen(words: sampleWords))),
            ),
            _buildHubTile(
              context: context,
              title: 'تركيب الجمل',
              subtitle: 'ترتيب الكلمات تفاعلياً',
              icon: Icons.sort_by_alpha_rounded,
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SentenceScrambleScreen(
                    originalSentence: 'Ich lerne jeden Tag Deutsch',
                    translation: 'أنا أتعلم اللغة الألمانية كل يوم',
                  ),
                ),
              ),
            ),
            _buildHubTile(
              context: context,
              title: 'تصريف الأفعال',
              subtitle: 'جداول الحاضر والتام',
              icon: Icons.bolt_rounded,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerbConjugatorScreen())),
            ),
            _buildHubTile(
              context: context,
              title: 'البحث الشامل',
              subtitle: 'بحث فوري بدون تشكيل',
              icon: Icons.search_rounded,
              color: Colors.cyan.shade700,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SmartWordSearch(
                    words: sampleWords,
                    onWordTap: (_) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 22,
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
