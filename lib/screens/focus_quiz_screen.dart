import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class FocusQuizScreen extends StatefulWidget {
  const FocusQuizScreen({super.key, this.sourceLocale = 'ar', this.targetLocale = 'de'});
  final String sourceLocale;
  final String targetLocale;

  @override
  State<FocusQuizScreen> createState() => _FocusQuizScreenState();
}


class _FocusQuizScreenState extends State<FocusQuizScreen> {
  // متغيرات مؤقت التركيز العميق (Pomodoro)
  int _remainingSeconds = 900; // 15 دقيقة تركيز هادئ
  bool _isTimerRunning = false;
  Timer? _timer;

  int _currentQuizIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  String _feedbackMessage = '';
  bool _isCorrect = false;
  bool _isSubmitting = false;

  List<LexicalEntry> _quizItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final allEntries = LexicalRepository.getEntriesForPair(
      sourceLocale: widget.sourceLocale,
      targetLocale: widget.targetLocale,
    );

    // Filter items to ensure we have content to quiz on
    _quizItems = allEntries.take(10).toList();

    setState(() {
      _isLoading = false;
    });
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

  Future<void> _checkAnswer() async {
    if (_isSubmitting) return;

    final currentEntry = _quizItems[_currentQuizIndex];
    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = currentEntry.targetTerm.toLowerCase();

    setState(() {
      _isSubmitting = true;
    });

    HapticFeedback.lightImpact();
    if (userAnswer == correctAnswer) {
      setState(() {
        _isCorrect = true;
        _feedbackMessage = '✨ ممتاز! استدعاء ذهني دقيق وصحيح.';
      });

      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: currentEntry.id,
        rating: 2,
        sourceIso: widget.sourceLocale,
        targetIso: widget.targetLocale,
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _answerController.clear();
          _feedbackMessage = '';
          _isSubmitting = false;
          if (_currentQuizIndex < _quizItems.length - 1) {
            _currentQuizIndex++;
          } else {
             _quizItems = []; // done
          }
        });
      }
    } else {
      setState(() {
        _isCorrect = false;
        _feedbackMessage = '💡 حاول مجدداً بهدوء، الدماغ يتعلم من المحاولة!';
        _isSubmitting = false;
      });

      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: currentEntry.id,
        rating: 0,
        sourceIso: widget.sourceLocale,
        targetIso: widget.targetLocale,
      );
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_quizItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('استوديو التركيز والاختبارات الهادئة'), backgroundColor: Colors.transparent, elevation: 0),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
          child: const Center(
            child: Text('لا يوجد محتوى متاح', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      );
    }

    final currentEntry = _quizItems[_currentQuizIndex];
    final targetDir = LanguageBiDiHelper.getDirection(widget.targetLocale);
    final sourceDir = LanguageBiDiHelper.getDirection(widget.sourceLocale);

    String displaySentence = currentEntry.sourceMeaning;
    bool isCloze = false;

    // Attempt cloze deletion if example exists and contains target term
    if (currentEntry.targetExample.isNotEmpty) {
      // Basic case-insensitive check
      if (currentEntry.targetExample.toLowerCase().contains(currentEntry.targetTerm.toLowerCase())) {
        displaySentence = currentEntry.targetExample.replaceAll(
          RegExp(RegExp.escape(currentEntry.targetTerm), caseSensitive: false),
          '___'
        );
        isCloze = true;
      }
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
                      Text(isCloze ? '🧩 مختبر الفراغات السياقية' : '🧩 اختبار الترجمة المباشرة', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Directionality(
                        textDirection: isCloze ? targetDir : sourceDir,
                        child: Text(
                          displaySentence,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: sourceDir,
                        child: Text(
                          'تلميح: ${currentEntry.sourceMeaning}',
                          style: const TextStyle(color: Color(0xFF34D399), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Directionality(
                        textDirection: targetDir,
                        child: TextField(
                          controller: _answerController,
                          enabled: !_isSubmitting,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'اكتب الكلمة الناقصة هنا...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
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
                        onPressed: _isSubmitting ? null : _checkAnswer,
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
