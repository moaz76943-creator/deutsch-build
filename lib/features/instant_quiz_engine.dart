import 'dart:math';
import 'package:flutter/material.dart';

class InstantQuizScreen extends StatefulWidget {
  final List<Map<String, String>> words;

  const InstantQuizScreen({super.key, required this.words});

  @override
  State<InstantQuizScreen> createState() => _InstantQuizScreenState();
}

class _InstantQuizScreenState extends State<InstantQuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  List<String> _options = [];
  String? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    if (widget.words.length < 4) return;
    _answered = false;
    _selectedAnswer = null;

    final currentWord = widget.words[_currentIndex];
    final correctAnswer = currentWord['arabic'] ?? '';

    final random = Random();
    final otherOptions = widget.words
        .where((w) => (w['arabic'] ?? '') != correctAnswer)
        .map((w) => w['arabic'] ?? '')
        .toList();

    otherOptions.shuffle(random);
    final selectedWrong = otherOptions.take(3).toList();

    _options = [correctAnswer, ...selectedWrong]..shuffle(random);
  }

  void _handleSelect(String answer) {
    if (_answered) return;
    final correctAnswer = widget.words[_currentIndex]['arabic'] ?? '';
    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (answer == correctAnswer) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _generateQuestion();
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('نتيجة الاختبار', textAlign: TextAlign.center),
        content: Text(
          'أحسنت! نتيجتك: $_score من أصل ${widget.words.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.length < 4) {
      return Scaffold(
        appBar: AppBar(title: const Text('اختبار سريع')),
        body: const Center(
          child: Text('تحتاج إلى 4 كلمات على الأقل لتشغيل الاختبار.'),
        ),
      );
    }

    final currentWord = widget.words[_currentIndex];
    final correctAnswer = currentWord['arabic'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('سؤال ${_currentIndex + 1} / ${widget.words.length}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                  child: Text(
                    currentWord['german'] ?? '',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ..._options.map((option) {
                Color btnColor = Colors.white;
                if (_answered) {
                  if (option == correctAnswer) {
                    btnColor = Colors.green.shade100;
                  } else if (option == _selectedAnswer) {
                    btnColor = Colors.red.shade100;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: btnColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleSelect(option),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (_answered)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex < widget.words.length - 1 ? 'السؤال التالي' : 'عرض النتيجة',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
