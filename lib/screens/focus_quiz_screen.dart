import 'dart:async';

import 'package:deutsch_bilarabi/core/services/pack_manager.dart';
import 'package:deutsch_bilarabi/features/flashcards/language_aware_answer_validator.dart';
import 'package:deutsch_bilarabi/features/flashcards/learning_review_coordinator.dart';
import 'package:deutsch_bilarabi/features/flashcards/verified_exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deutsch_bilarabi/design_system/design_system.dart';

class FocusQuizScreen extends StatefulWidget {
  const FocusQuizScreen({
    super.key,
    this.conceptId,
    this.sourceLanguageCode = 'ar',
    this.targetLanguageCode = 'de',
    this.exerciseLoader,
    this.reviewCoordinator,
  });

  final String? conceptId;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final VerifiedExerciseLoader? exerciseLoader;
  final LearningReviewCoordinator? reviewCoordinator;

  @override
  State<FocusQuizScreen> createState() => _FocusQuizScreenState();
}

class _FocusQuizScreenState extends State<FocusQuizScreen> {
  int _remainingSeconds = 900;
  bool _isTimerRunning = false;
  Timer? _timer;

  final List<VerifiedExercise> _exercises = <VerifiedExercise>[];
  final TextEditingController _answerController = TextEditingController();
  late final LearningReviewCoordinator _reviewCoordinator;
  late final bool _ownsReviewCoordinator;
  late final String _sessionId;

  int _currentQuizIndex = 0;
  int _loadGeneration = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isResolved = false;
  bool _isCorrect = false;
  bool _sessionComplete = false;
  String? _unavailableMessage;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _sessionId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    _ownsReviewCoordinator = widget.reviewCoordinator == null;
    _reviewCoordinator = widget.reviewCoordinator ??
        LearningReviewCoordinator(
          writer: ({
            required learnerContentId,
            required targetLanguageCode,
            required grade,
          }) async {
            await PackManager.recordQuizResult(
              conceptId: learnerContentId,
              isCorrect: grade >= 3,
              languageCode: targetLanguageCode,
            );
          },
        );
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final conceptId = widget.conceptId?.trim() ?? '';
    final generation = ++_loadGeneration;
    if (conceptId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _unavailableMessage =
              'لا يوجد تمرين استدعاء موثّق محدد لهذا السياق. لم يتم إنشاء مثال بديل.';
        });
      }
      return;
    }

    final loader = widget.exerciseLoader ??
        (String concept, String language) => PackManager.getExercises(
              concept,
              languageCode: language,
            );

    try {
      final rows = await loader(conceptId, widget.targetLanguageCode);
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      final parsed = rows
          .map(
            (row) => VerifiedExercise.fromPackRow(
              row,
              conceptId: conceptId,
              languageCode: widget.targetLanguageCode,
            ),
          )
          .toList(growable: false);
      setState(() {
        _exercises
          ..clear()
          ..addAll(parsed);
        _isLoading = false;
        _currentQuizIndex = 0;
        _answerController.clear();
        _feedbackMessage = '';
        _isResolved = false;
        _sessionComplete = false;
        if (parsed.isEmpty) {
          _unavailableMessage =
              'لا يتوفر تمرين استدعاء موثّق لهذا المفهوم في الحزمة المحلية.';
        }
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      setState(() {
        _isLoading = false;
        _unavailableMessage =
            'تعذر تحميل تمرين الاستدعاء الموثّق. لم يتم احتساب أي نتيجة.';
      });
    }
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isTimerRunning = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
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
    if (!mounted) {
      return;
    }
    setState(() {
      _isTimerRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return minutes.toString().padLeft(2, '0') +
        ':' +
        secs.toString().padLeft(2, '0');
  }

  Future<void> _checkAnswer() async {
    if (_isSubmitting || _isResolved || _exercises.isEmpty) {
      return;
    }
    final exercise = _exercises[_currentQuizIndex];
    final result = LanguageAwareAnswerValidator.validate(
      answer: _answerController.text,
      acceptedAnswers: <String>[exercise.correctAnswer],
      languageCode: exercise.languageCode,
    );
    if (result == AnswerValidationResult.unavailable) {
      setState(() {
        _isResolved = true;
        _feedbackMessage =
            'الإجابة المرجعية غير متاحة؛ لم يتم احتساب النتيجة.';
      });
      return;
    }

    final correct = result == AnswerValidationResult.correct;
    final eventId = 'focus:' +
        _sessionId +
        ':' +
        exercise.stableKey +
        ':' +
        _currentQuizIndex.toString();

    HapticFeedback.lightImpact();
    setState(() {
      _isSubmitting = true;
    });
    try {
      final status = await _reviewCoordinator.submit(
        eventId: eventId,
        learnerContentId: exercise.conceptId,
        sourceLanguageCode: widget.sourceLanguageCode,
        targetLanguageCode: widget.targetLanguageCode,
        grade: correct ? 3 : 0,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isCorrect = correct;
        _isResolved = true;
        _feedbackMessage = status == ReviewSubmissionStatus.accepted
            ? (correct
                ? 'إجابة صحيحة. تم حفظ الاستدعاء محلياً.'
                : 'إجابة غير صحيحة. تم حفظ المراجعة محلياً دون تغيير الإجابة المرجعية.')
            : status == ReviewSubmissionStatus.duplicate
                ? 'تم تجاهل محاولة مكررة ولم تُحتسب مرتين.'
                : 'تعذر الوصول إلى مخزن المراجعة.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedbackMessage = 'تعذر حفظ النتيجة؛ لم يتم احتسابها.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _skipExercise() {
    if (_isSubmitting || _isResolved || _exercises.isEmpty) {
      return;
    }
    setState(() {
      _isCorrect = false;
      _isResolved = true;
      _feedbackMessage = 'تم تخطي التمرين دون تعديل سجل SRS.';
    });
  }

  void _nextExercise() {
    if (!_isResolved || _exercises.isEmpty) {
      return;
    }
    if (_currentQuizIndex >= _exercises.length - 1) {
      setState(() {
        _sessionComplete = true;
      });
      return;
    }
    setState(() {
      _currentQuizIndex++;
      _answerController.clear();
      _feedbackMessage = '';
      _isResolved = false;
      _isCorrect = false;
    });
  }

  @override
  void dispose() {
    _loadGeneration++;
    _timer?.cancel();
    _answerController.dispose();
    if (_ownsReviewCoordinator) {
      _reviewCoordinator.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استوديو التركيز والاستدعاء'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                _buildTimerCard(),
                const SizedBox(height: 24),
                _buildExerciseCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return AppBaseGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const Text(
            'وضع التركيز',
            style: TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTimerRunning
                  ? Colors.redAccent
                  : const Color(0xFF34D399),
              foregroundColor: Colors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isTimerRunning ? _stopTimer : _startTimer,
            icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
            label: Text(
              _isTimerRunning ? 'إيقاف مؤقت' : 'ابدأ جلسة التركيز',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard() {
    if (_isLoading) {
      return const AppBaseGlassCard(
        padding: EdgeInsets.all(28),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_unavailableMessage != null) {
      return AppBaseGlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Text(
              _unavailableMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if ((widget.conceptId?.trim() ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadExercises,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      );
    }
    if (_sessionComplete) {
      return const AppBaseGlassCard(
        padding: EdgeInsets.all(24),
        child: Text(
          'اكتملت تمارين الاستدعاء الموثّقة المتاحة.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final exercise = _exercises[_currentQuizIndex];
    return AppBaseGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'استدعاء ' +
                (_currentQuizIndex + 1).toString() +
                ' / ' +
                _exercises.length.toString(),
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            exercise.prompt,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _answerController,
            enabled: !_isResolved && !_isSubmitting,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _checkAnswer(),
            decoration: InputDecoration(
              hintText: 'اكتب الإجابة كما هي في اللغة المستهدفة...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!_isResolved) ...<Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSubmitting ? null : _checkAnswer,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'تحقق من الإجابة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            TextButton(
              onPressed: _isSubmitting ? null : _skipExercise,
              child: const Text('تخطي دون احتساب'),
            ),
          ] else
            ElevatedButton(
              onPressed: _nextExercise,
              child: Text(
                _currentQuizIndex == _exercises.length - 1
                    ? 'إنهاء'
                    : 'التالي',
              ),
            ),
          if (_feedbackMessage.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _feedbackMessage,
              style: TextStyle(
                color:
                    _isCorrect ? const Color(0xFF34D399) : Colors.orangeAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
