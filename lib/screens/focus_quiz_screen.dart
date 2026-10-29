import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

class FocusQuizScreen extends StatefulWidget {
  const FocusQuizScreen({super.key});

  @override
  State<FocusQuizScreen> createState() => _FocusQuizScreenState();
}

class _FocusQuizScreenState extends State<FocusQuizScreen> {
  int _remainingSeconds = 900;
  bool _isTimerRunning = false;
  Timer? _timer;

  List<LexicalEntry> _entries = [];
  int _currentQuizIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  String _feedbackMessage = '';
  bool _isCorrect = false;
  bool _isSubmitting = false;
  bool _hasAnsweredCurrent = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final allEntries = LexicalRepository.getEntriesByDomain('general');
    if (allEntries.isNotEmpty) {
      _entries = allEntries.where((e) => e.targetExample.isNotEmpty).toList();
      _entries.shuffle();
    }
  }

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
        _handleTimerExpired();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _handleTimerExpired() {
    setState(() {
      _feedbackMessage = '⏰ انتهى الوقت! أخذ استراحة قصيرة.';
      _isSubmitting = true;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _checkAnswer() async {
    if (_isSubmitting || _entries.isEmpty || _hasAnsweredCurrent) return;

    final currentEntry = _entries[_currentQuizIndex];
    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = currentEntry.targetTerm.toLowerCase();

    HapticFeedback.lightImpact();

    setState(() {
      _isSubmitting = true;
      _hasAnsweredCurrent = true;
    });

    final isCorrectAnswer = userAnswer == correctAnswer;
    final rating = isCorrectAnswer ? 3 : 1;

    try {
      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: currentEntry.id,
        rating: rating,
        sourceIso: currentEntry.sourceLocale,
        targetIso: currentEntry.targetLocale,
      );

      if (isCorrectAnswer) {
        if (mounted) {
          setState(() {
            _isCorrect = true;
            _feedbackMessage = '✨ ممتاز! استدعاء ذهني دقيق وصحيح.';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isCorrect = false;
            _feedbackMessage =
                '💡 الإجابة الصحيحة هي: ${currentEntry.targetTerm}';
          });
        }
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _answerController.clear();
            _feedbackMessage = '';
            _currentQuizIndex = (_currentQuizIndex + 1) % _entries.length;
            _isSubmitting = false;
            _hasAnsweredCurrent = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _hasAnsweredCurrent = false;
        });
      }
    }
  }

  void _skipQuestion() {
    if (_isSubmitting || _entries.isEmpty) return;
    setState(() {
      _answerController.clear();
      _feedbackMessage = '';
      _currentQuizIndex = (_currentQuizIndex + 1) % _entries.length;
      _hasAnsweredCurrent = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('استوديو التركيز والاختبارات الهادئة'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
          child: const Center(
            child: Text(
              'لا يوجد محتوى متاح حالياً',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );
    }

    final currentEntry = _entries[_currentQuizIndex];
    final targetExample = currentEntry.targetExample;
    final targetTerm = currentEntry.targetTerm;

    String clozeSentence = targetExample.replaceAll(
        RegExp(RegExp.escape(targetTerm), caseSensitive: false), '___');
    if (clozeSentence == targetExample) {
      clozeSentence = '$targetExample (___)';
    }

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
                      const Text('🧘 وضع التركيز العميق (Flow State)',
                          style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
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
                          backgroundColor: _isTimerRunning
                              ? Colors.redAccent
                              : const Color(0xFF34D399),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                        icon: Icon(
                            _isTimerRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(
                            _isTimerRunning
                                ? 'إيقاف مؤقت للراحة'
                                : 'ابدأ جلسة التركيز',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('🧩 مختبر الفراغات السياقية',
                              style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white70),
                            onPressed: _skipQuestion,
                            tooltip: 'تخطي',
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Directionality(
                        textDirection: LanguageBiDiHelper.getDirection(
                            currentEntry.targetLocale),
                        child: Text(
                          clozeSentence,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: LanguageBiDiHelper.getDirection(
                            currentEntry.sourceLocale),
                        child: Text(
                          'تلميح: ${currentEntry.sourceMeaning}',
                          style: const TextStyle(
                              color: Color(0xFF34D399), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Directionality(
                        textDirection: LanguageBiDiHelper.getDirection(
                            currentEntry.targetLocale),
                        child: TextField(
                          controller: _answerController,
                          style: const TextStyle(color: Colors.white),
                          enabled: !_isSubmitting,
                          decoration: InputDecoration(
                            hintText: 'اكتب الكلمة الناقصة هنا...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSubmitting || _hasAnsweredCurrent
                            ? null
                            : _checkAnswer,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black))
                            : const Text('تحقق من الإجابة بهدوء',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      if (_feedbackMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _feedbackMessage,
                          style: TextStyle(
                              color: _isCorrect
                                  ? const Color(0xFF34D399)
                                  : Colors.orangeAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
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
