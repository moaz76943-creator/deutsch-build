import 'package:flutter/material.dart';
import '../services/progress_storage_service.dart';

class ArticlesQuizScreen extends StatefulWidget {
  const ArticlesQuizScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesQuizScreen> createState() => _ArticlesQuizScreenState();
}

class _ArticlesQuizScreenState extends State<ArticlesQuizScreen> {
  final List<Map<String, dynamic>> _questions = const [
    {'word': 'Tisch', 'meaning': 'طاولة', 'correct': 'der'},
    {'word': 'Sonne', 'meaning': 'شمس', 'correct': 'die'},
    {'word': 'Buch', 'meaning': 'كتاب', 'correct': 'das'},
    {'word': 'Stuhl', 'meaning': 'كرسي', 'correct': 'der'},
    {'word': 'Lampe', 'meaning': 'مصباح', 'correct': 'die'},
    {'word': 'Auto', 'meaning': 'سيارة', 'correct': 'das'},
    {'word': 'Apfel', 'meaning': 'تفاحة', 'correct': 'der'},
    {'word': 'Katze', 'meaning': 'قطة', 'correct': 'die'},
    {'word': 'Haus', 'meaning': 'منزل', 'correct': 'das'},
  ];

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  void _submitAnswer(String article) async {
    if (_answered) return;
    final isCorrect = article == _questions[_currentIndex]['correct'];
    setState(() {
      _selectedAnswer = article;
      _answered = true;
      if (isCorrect) {
        _score += 10;
      }
    });

    if (isCorrect) {
      await ProgressStorageService.addPoints(10);
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          if (_currentIndex < _questions.length - 1) {
            _currentIndex++;
            _selectedAnswer = null;
            _answered = false;
          } else {
            _showFinishDialog();
          }
        });
      }
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('أحسنت! إنجاز رائع 🏆', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('لقد جمعت $_score نقطة جديدة تمت إضافتها إلى رصيدك الإجمالي!', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 48),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('العودة للرئيسية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text('Articles Challenge / تحدي الأدوات', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('+$_score Pts', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('السؤال ${_currentIndex + 1} من ${_questions.length}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  const Text('اختر أداة التعريف المناسبة:', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 16),
                  Text(
                    q['word'],
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q['meaning'],
                    style: const TextStyle(fontSize: 16, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _buildArticleButton('der', const Color(0xFF2563EB), q['correct']),
                const SizedBox(width: 12),
                _buildArticleButton('die', const Color(0xFFEC4899), q['correct']),
                const SizedBox(width: 12),
                _buildArticleButton('das', const Color(0xFF10B981), q['correct']),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleButton(String article, Color defaultColor, String correct) {
    Color bg = Colors.white;
    Color border = defaultColor.withValues(alpha: 0.3);
    Color textCol = defaultColor;

    if (_answered) {
      if (article == correct) {
        bg = const Color(0xFF10B981);
        border = const Color(0xFF10B981);
        textCol = Colors.white;
      } else if (article == _selectedAnswer) {
        bg = const Color(0xFFEF4444);
        border = const Color(0xFFEF4444);
        textCol = Colors.white;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _submitAnswer(article),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 2),
            boxShadow: [
              BoxShadow(color: defaultColor.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Text(
              article,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textCol),
            ),
          ),
        ),
      ),
    );
  }
}
