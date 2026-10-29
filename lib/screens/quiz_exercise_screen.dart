import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

import 'dart:math';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

class QuizExerciseScreen extends StatefulWidget {
  const QuizExerciseScreen({super.key, this.sourceLocale = 'ar', this.targetLocale = 'de'});
  final String sourceLocale;
  final String targetLocale;

  @override
  State<QuizExerciseScreen> createState() => _QuizExerciseScreenState();
}


class _QuestionData {
  final LexicalEntry entry;
  final List<String> options;
  final int correctIndex;

  _QuestionData({required this.entry, required this.options, required this.correctIndex});
}

class _QuizExerciseScreenState extends State<QuizExerciseScreen> {
  int? _selectedOption;
  bool _isSubmitting = false;
  int _currentQuestionIndex = 0;
  List<_QuestionData> _questions = [];
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

    if (allEntries.length >= 4) {
      final random = Random();
      final questions = <_QuestionData>[];
      for (final entry in allEntries) {
        final distractors = allEntries
            .where((e) => e.id != entry.id)
            .map((e) => e.targetTerm)
            .toList()
          ..shuffle(random);

        if (distractors.length < 3) continue;

        final options = distractors.take(3).toList()..add(entry.targetTerm);
        options.shuffle(random);
        questions.add(_QuestionData(
          entry: entry,
          options: options,
          correctIndex: options.indexOf(entry.targetTerm),
        ));
      }
      questions.shuffle(random);
      _questions = questions.take(10).toList(); // Max 10 questions per session
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkAnswer() async {
    if (_selectedOption == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final currentQ = _questions[_currentQuestionIndex];
    final isCorrect = _selectedOption == currentQ.correctIndex;

    await SrsCompatBridge.instance.recordReviewCompat(
      contentKey: currentQ.entry.id,
      rating: isCorrect ? 2 : 0,
      sourceIso: widget.sourceLocale,
      targetIso: widget.targetLocale,
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _selectedOption = null;
        _isSubmitting = false;
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          _questions = []; // Finished state
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('تمرين القواعد'), backgroundColor: Colors.transparent, elevation: 0),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
          child: const Center(
            child: Text('لا يوجد محتوى كافٍ (4 مفردات على الأقل)', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      );
    }

    final currentQ = _questions[_currentQuestionIndex];
    final dir = LanguageBiDiHelper.getDirection(widget.targetLocale);
    final promptDir = LanguageBiDiHelper.getDirection(widget.sourceLocale);

    return Scaffold(
      appBar: AppBar(
        title: Text('تمرين (${_currentQuestionIndex + 1}/${_questions.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Directionality(
                  textDirection: promptDir,
                  child: Text(
                    'اختر الترجمة الصحيحة للكلمة التالية:',
                    style: AppTypography.title.copyWith(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),
                AppBaseGlassCard(
                  gradient: AppGradients.purpleCard,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Directionality(
                      textDirection: promptDir,
                      child: Text(
                        currentQ.entry.sourceMeaning,
                        style: AppTypography.display.copyWith(color: Colors.white, fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: dir,
                  child: Column(
                    children: List.generate(currentQ.options.length, (index) {
                      final isSelected = _selectedOption == index;
                      final isAnswerRevealed = _isSubmitting;
                      final isCorrectOption = index == currentQ.correctIndex;

                      Gradient? customGrad;
                      if (isAnswerRevealed) {
                        if (isCorrectOption) {
                          customGrad = const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF047857)]);
                        } else if (isSelected && !isCorrectOption) {
                          customGrad = const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFFB91C1C)]);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppBaseGlassCard(
                          onTap: _isSubmitting ? null : () => setState(() => _selectedOption = index),
                          gradient: customGrad,
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  currentQ.options[index],
                                  style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedOption == null || _isSubmitting ? null : _checkAnswer,
                  child: const Text('تحقق من الإجابة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
