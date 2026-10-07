import 'package:flutter/material.dart';
import '../services/progress_storage_service.dart';
import '../services/tts_service.dart';

class LessonSessionScreen extends StatefulWidget {
  final String unitTitle;
  final String level;
  final String languageCode;

  const LessonSessionScreen({
    Key? key,
    required this.unitTitle,
    required this.level,
    this.languageCode = 'de',
  }) : super(key: key);

  @override
  State<LessonSessionScreen> createState() => _LessonSessionScreenState();
}

class _LessonSessionScreenState extends State<LessonSessionScreen> {
  final TtsService _tts = TtsService();

  final List<Map<String, dynamic>> _quizData = const [
    {
      'question': 'كيف تقول "صباح الخير" باللغة الألمانية؟',
      'phrase': 'Guten Morgen',
      'options': ['Guten Abend', 'Guten Morgen', 'Auf Wiedersehen', 'Gute Nacht'],
      'correct': 'Guten Morgen',
    },
    {
      'question': 'ما معنى عبارة "Danke schön"؟',
      'phrase': 'Danke schön',
      'options': ['عفواً', 'أهلاً وسهلاً', 'شكراً جزيلاً', 'مع السلامة'],
      'correct': 'شكراً جزيلاً',
    },
    {
      'question': 'اختر العبارة الصحيحة لـ "أنا بخير، شكراً":',
      'phrase': 'Mir geht es gut, danke',
      'options': ['Mir geht es gut, danke', 'Wie geht es dir?', 'Ich heiße Max', 'Bitte sehr'],
      'correct': 'Mir geht es gut, danke',
    },
    {
      'question': 'كيف تسأل شخصاً عن اسمه؟',
      'phrase': 'Wie heißen Sie?',
      'options': ['Woher kommen Sie?', 'Wie alt sind Sie?', 'Wie heißen Sie?', 'Was machen Sie?'],
      'correct': 'Wie heißen Sie?',
    },
  ];

  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  int _earnedPoints = 0;

  void _checkAnswer(String option) async {
    if (_isAnswered) return;
    final current = _quizData[_currentIndex];
    final isCorrect = option == current['correct'];

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
      if (isCorrect) {
        _earnedPoints += 15;
      }
    });

    if (isCorrect) {
      await ProgressStorageService.addPoints(15);
    }

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        if (_currentIndex < _quizData.length - 1) {
          setState(() {
            _currentIndex++;
            _selectedOption = null;
            _isAnswered = false;
          });
        } else {
          _showCompletionSheet();
        }
      }
    });
  }

  void _showCompletionSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 48, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 16),
            const Text(
              'أحسنت! أكملت الدرس بنجاح 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'حصلت على +$_earnedPoints نقطة وأحرزت تقدماً في المسار!',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: const Text('متابعة المسار التعليمي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _quizData[_currentIndex];
    final progress = (_currentIndex + 1) / _quizData.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.unitTitle, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold)),
            Text('مستوى ${widget.level} • تدريب تفاعلي', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('+$_earnedPoints Pts', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 10),
            Text('السؤال ${_currentIndex + 1} من ${_quizData.length}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    current['question'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        current['phrase'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB)),
                        onPressed: () => _tts.speak(current['phrase'], langCode: widget.languageCode),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: (current['options'] as List).length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final opt = (current['options'] as List)[idx];
                  Color bg = Colors.white;
                  Color border = const Color(0xFFE2E8F0);
                  Color textCol = const Color(0xFF0F172A);

                  if (_isAnswered) {
                    if (opt == current['correct']) {
                      bg = const Color(0xFFECFDF5);
                      border = const Color(0xFF10B981);
                      textCol = const Color(0xFF059669);
                    } else if (opt == _selectedOption) {
                      bg = const Color(0xFFFEF2F2);
                      border = const Color(0xFFEF4444);
                      textCol = const Color(0xFFDC2626);
                    }
                  }

                  return InkWell(
                    onTap: () => _checkAnswer(opt),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFF1F5F9),
                            child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
                            ),
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
    );
  }
}
