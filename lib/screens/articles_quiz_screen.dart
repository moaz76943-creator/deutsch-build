import 'package:flutter/material.dart';

class ArticlesQuizScreen extends StatefulWidget {
  const ArticlesQuizScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesQuizScreen> createState() => _ArticlesQuizScreenState();
}

class _ArticlesQuizScreenState extends State<ArticlesQuizScreen> {
  final List<Map<String, dynamic>> _quizData = [
    {'word': 'Tisch', 'meaning': 'طاولة', 'correct': 'der', 'plural': 'die Tische'},
    {'word': 'Sonne', 'meaning': 'شمس', 'correct': 'die', 'plural': 'die Sonnen'},
    {'word': 'Buch', 'meaning': 'كتاب', 'correct': 'das', 'plural': 'die Bücher'},
    {'word': 'Apfel', 'meaning': 'تفاحة', 'correct': 'der', 'plural': 'die Äpfel'},
    {'word': 'Stadt', 'meaning': 'مدينة', 'correct': 'die', 'plural': 'die Städte'},
    {'word': 'Auto', 'meaning': 'سيارة', 'correct': 'das', 'plural': 'die Autos'},
    {'word': 'Lehrer', 'meaning': 'معلم', 'correct': 'der', 'plural': 'die Lehrer'},
    {'word': 'Schule', 'meaning': 'مدرسة', 'correct': 'die', 'plural': 'die Schulen'},
    {'word': 'Haus', 'meaning': 'منزل', 'correct': 'das', 'plural': 'die Häuser'},
    {'word': 'Mond', 'meaning': 'قمر', 'correct': 'der', 'plural': 'die Monde'},
  ];

  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  String? _selectedAnswer;
  bool _answered = false;

  void _checkAnswer(String article) {
    if (_answered) return;

    final isCorrect = article == _quizData[_currentIndex]['correct'];
    setState(() {
      _selectedAnswer = article;
      _answered = true;
      if (isCorrect) {
        _score += 10;
        _streak += 1;
      } else {
        _streak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        if (_currentIndex < _quizData.length - 1) {
          _currentIndex++;
          _answered = false;
          _selectedAnswer = null;
        } else {
          _showCompletionDialog();
        }
      });
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('إنجاز رائع!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('حصلت على $_score نقطة من إجمالي ${_quizData.length * 10} نقطة.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _streak = 0;
                _answered = false;
                _selectedAnswer = null;
              });
            },
            child: const Text('إعادة التدريب', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('العودة للرئيسية', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _quizData[_currentIndex];
    final progress = (_currentIndex + 1) / _quizData.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text('تحدي أدوات التعريف', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text('$_score نقطة', style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
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
                value: progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سؤال ${_currentIndex + 1} من ${_quizData.length}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                if (_streak > 1)
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                      Text('سلسلة حماسية: $_streak', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10)),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('ما هي أداة التعريف الصحيحة؟', style: TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentItem['word'],
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentItem['meaning'],
                    style: const TextStyle(fontSize: 18, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الجمع: ${currentItem['plural']}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _buildChoiceButton('der', 'مذكر', const Color(0xFF2563EB), currentItem['correct']),
                const SizedBox(width: 12),
                _buildChoiceButton('die', 'مؤنث', const Color(0xFFEC4899), currentItem['correct']),
                const SizedBox(width: 12),
                _buildChoiceButton('das', 'محايد', const Color(0xFF10B981), currentItem['correct']),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String article, String label, Color defaultColor, String correctArticle) {
    Color btnColor = defaultColor;
    if (_answered) {
      if (article == correctArticle) {
        btnColor = Colors.green;
      } else if (article == _selectedAnswer) {
        btnColor = Colors.red;
      } else {
        btnColor = Colors.grey.shade400;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _checkAnswer(article),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: btnColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: btnColor, width: _selectedAnswer == article ? 2.5 : 1.5),
          ),
          child: Column(
            children: [
              Text(
                article,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: btnColor),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: btnColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
