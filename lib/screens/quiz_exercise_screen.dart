import 'package:deutsch_bilarabi/core/services/pack_manager.dart';
import 'package:deutsch_bilarabi/features/flashcards/language_aware_answer_validator.dart';
import 'package:deutsch_bilarabi/features/flashcards/learning_review_coordinator.dart';
import 'package:deutsch_bilarabi/features/flashcards/verified_exercise.dart';
import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

class QuizExerciseScreen extends StatefulWidget {
  const QuizExerciseScreen({
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
  State<QuizExerciseScreen> createState() => _QuizExerciseScreenState();
}

class _QuizExerciseScreenState extends State<QuizExerciseScreen> {
  final List<VerifiedExercise> _exercises = <VerifiedExercise>[];
  late final LearningReviewCoordinator _reviewCoordinator;
  late final bool _ownsReviewCoordinator;
  late final String _sessionId;

  int _currentIndex = 0;
  int _loadGeneration = 0;
  String? _selectedOption;
  String? _feedback;
  String? _unavailableMessage;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isResolved = false;
  bool _isSkipped = false;
  bool _sessionComplete = false;

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
              'لا يوجد تمرين موثّق محدد لهذا السياق. لم يتم إنشاء سؤال بديل.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _unavailableMessage = null;
      });
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
      final parsed = <VerifiedExercise>[];
      for (final row in rows) {
        parsed.add(
          VerifiedExercise.fromPackRow(
            row,
            conceptId: conceptId,
            languageCode: widget.targetLanguageCode,
          ),
        );
      }
      setState(() {
        _exercises
          ..clear()
          ..addAll(parsed);
        _currentIndex = 0;
        _selectedOption = null;
        _feedback = null;
        _isResolved = false;
        _isSkipped = false;
        _sessionComplete = false;
        _isLoading = false;
        if (parsed.isEmpty) {
          _unavailableMessage =
              'لا يتوفر تمرين موثّق لهذا المفهوم في الحزمة المحلية.';
        }
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      setState(() {
        _isLoading = false;
        _unavailableMessage =
            'تعذر تحميل التمرين الموثّق. لم يتم احتساب أي نتيجة.';
      });
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    if (_ownsReviewCoordinator) {
      _reviewCoordinator.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAnswer() async {
    if (_selectedOption == null ||
        _isResolved ||
        _isSubmitting ||
        _exercises.isEmpty) {
      return;
    }

    final exercise = _exercises[_currentIndex];
    final validation = LanguageAwareAnswerValidator.validate(
      answer: _selectedOption!,
      acceptedAnswers: <String>[exercise.correctAnswer],
      languageCode: exercise.languageCode,
    );
    if (validation == AnswerValidationResult.unavailable) {
      setState(() {
        _feedback = 'الإجابة المرجعية غير متاحة؛ لم يتم احتساب النتيجة.';
        _isResolved = true;
      });
      return;
    }

    final isCorrect = validation == AnswerValidationResult.correct;
    final eventId =
        'quiz:' + _sessionId + ':' + exercise.stableKey + ':' + _currentIndex.toString();

    setState(() {
      _isSubmitting = true;
    });
    try {
      final status = await _reviewCoordinator.submit(
        eventId: eventId,
        learnerContentId: exercise.conceptId,
        sourceLanguageCode: widget.sourceLanguageCode,
        targetLanguageCode: widget.targetLanguageCode,
        grade: isCorrect ? 3 : 0,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isResolved = true;
        _feedback = status == ReviewSubmissionStatus.accepted
            ? (isCorrect
                ? 'إجابة صحيحة. تم حفظ المراجعة محلياً.'
                : 'إجابة غير صحيحة. تم حفظ المراجعة محلياً.')
            : status == ReviewSubmissionStatus.duplicate
                ? 'تم تجاهل محاولة مكررة ولم تُحتسب مرتين.'
                : 'لم تتوفر خدمة حفظ المراجعة.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = 'تعذر حفظ النتيجة محلياً؛ لم يتم احتسابها.';
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
      _isSkipped = true;
      _isResolved = true;
      _feedback = 'تم تخطي السؤال دون تعديل سجل SRS.';
    });
  }

  void _nextExercise() {
    if (!_isResolved || _exercises.isEmpty) {
      return;
    }
    if (_currentIndex >= _exercises.length - 1) {
      setState(() {
        _sessionComplete = true;
      });
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _feedback = null;
      _isResolved = false;
      _isSkipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تمرين موثّق'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_unavailableMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _unavailableMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: Colors.white70),
            ),
            if ((widget.conceptId?.trim() ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
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
      return Center(
        child: Text(
          'اكتملت التمارين الموثّقة المتاحة.',
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(color: Colors.white),
        ),
      );
    }

    final exercise = _exercises[_currentIndex];
    final options = exercise.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'السؤال ' +
              (_currentIndex + 1).toString() +
              ' من ' +
              _exercises.length.toString(),
          style: AppTypography.body.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 12),
        AppBaseGlassCard(
          gradient: AppGradients.purpleCard,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
          child: Text(
            exercise.prompt,
            textAlign: TextAlign.center,
            style: AppTypography.display.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = _selectedOption == option;
              final isCorrect = _isResolved &&
                  LanguageAwareAnswerValidator.validate(
                        answer: option,
                        acceptedAnswers: <String>[exercise.correctAnswer],
                        languageCode: exercise.languageCode,
                      ) ==
                      AnswerValidationResult.correct;
              final isWrongSelection =
                  _isResolved && isSelected && !isCorrect && !_isSkipped;

              Gradient? customGradient;
              if (isCorrect) {
                customGradient = const LinearGradient(
                  colors: <Color>[Color(0xFF065F46), Color(0xFF047857)],
                );
              } else if (isWrongSelection) {
                customGradient = const LinearGradient(
                  colors: <Color>[Color(0xFF991B1B), Color(0xFFB91C1C)],
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppBaseGlassCard(
                  onTap: _isResolved || _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _selectedOption = option;
                          });
                        },
                  gradient: customGradient,
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          style: AppTypography.title.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_feedback != null) ...<Widget>[
          Text(
            _feedback!,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
        ],
        if (_isResolved)
          ElevatedButton(
            onPressed: _nextExercise,
            child: Text(
              _currentIndex == _exercises.length - 1 ? 'إنهاء' : 'التالي',
            ),
          )
        else ...<Widget>[
          ElevatedButton(
            onPressed:
                _selectedOption == null || _isSubmitting ? null : _checkAnswer,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('تحقق من الإجابة'),
          ),
          TextButton(
            onPressed: _isSubmitting ? null : _skipExercise,
            child: const Text('تخطي دون احتساب'),
          ),
        ],
      ],
    );
  }
}
