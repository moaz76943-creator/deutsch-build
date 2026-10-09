import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../design_system/design_system.dart';

class FocusQuizScreen extends StatefulWidget {
  const FocusQuizScreen({super.key});

  @override
  State<FocusQuizScreen> createState() => _FocusQuizScreenState();
}

class _FocusQuizScreenState extends State<FocusQuizScreen> {
  // متغيرات مؤقت التركيز العميق (Pomodoro)
  int _remainingSeconds = 900; // 15 دقيقة تركيز هادئ
  bool _isTimerRunning = false;
  Timer? _timer;

  // اختبار الفراغات السياقية (Cloze Deletion)
  final List<Map<String, String>> _quizItems = [
    {"sentence": "Ich ___ ein Buch.", "target": "lese", "hint": "يقرأ (lesen)"},
    {"sentence": "Wir ___ nach Berlin.", "target": "fahren", "hint": "يسافر (fahren)"},
    {"sentence": "Das ___ ist sehr schön.", "target": "Auto", "hint": "سيارة (der/das? -> das)"},
  ];
  int _currentQuizIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  String _feedbackMessage = '';
  bool _isCorrect = false;

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _checkAnswer() {
    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = _quizItems[_currentQuizIndex]['target']!.toLowerCase();

    HapticFeedback.lightImpact();
    if (userAnswer == correctAnswer) {
      setState(() {
        _isCorrect = true;
        _feedbackMessage = '✨ ممتاز! استدعاء ذهني دقيق وصحيح.';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _answerController.clear();
            _feedbackMessage = '';
            _currentQuizIndex = (_currentQuizIndex + 1) % _quizItems.length;
          });
        }
      });
    } else {
      setState(() {
        _isCorrect = false;
        _feedbackMessage = '💡 حاول مجدداً بهدوء، الدماغ يتعلم من المحاولة!';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuiz = _quizItems[_currentQuizIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('استوديو التركيز والاختبارات الهادئة'),
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
                // قسم مؤقت التركيز العميق (Pomodoro)
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const Text('🧘 وضع التركيز العميق (Flow State)', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'جلسة هادئة ومخصصة لمنع التشتت وتثبيت المعلومات بعمق عصبي.',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTimerRunning ? Colors.redAccent : const Color(0xFF34D399),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                        icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isTimerRunning ? 'إيقاف مؤقت للراحة' : 'ابدأ جلسة التركيز', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // قسم اختبار الفراغات السياقية (Cloze Deletion)
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('🧩 مختبر الفراغات السياقية (Lückentext)', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        currentQuiz['sentence']!,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تلميح: ${currentQuiz['hint']}',
                        style: const TextStyle(color: Color(0xFF34D399), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _answerController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'اكتب الكلمة الناقصة هنا...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _checkAnswer,
                        child: const Text('تحقق من الإجابة بهدوء', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      if (_feedbackMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _feedbackMessage,
                          style: TextStyle(color: _isCorrect ? const Color(0xFF34D399) : Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
