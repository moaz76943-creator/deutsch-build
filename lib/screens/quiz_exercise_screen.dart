import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

class QuizExerciseScreen extends StatefulWidget {
  const QuizExerciseScreen({super.key});

  @override
  State<QuizExerciseScreen> createState() => _QuizExerciseScreenState();
}

class _QuizExerciseScreenState extends State<QuizExerciseScreen> {
  int? _selectedOption;

  List<LexicalEntry> _entries = [];
  LexicalEntry? _currentEntry;
  List<String> _options = [];
  int _correctOption = -1;
  bool _isAnswered = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final allEntries = LexicalRepository.getEntriesByDomain('general');
    if (allEntries.isNotEmpty) {
      _entries = List.from(allEntries)..shuffle();
      _prepareQuestion();
    }
  }

  void _prepareQuestion() {
    if (_entries.isEmpty) return;

    _currentEntry = _entries.first;
    _entries.removeAt(0);

    final allTerms = LexicalRepository.getEntriesByDomain('general')
        .map((e) => e.targetTerm)
        .toSet()
        .toList();
    allTerms.remove(_currentEntry!.targetTerm);
    allTerms.shuffle();

    final distractors = allTerms.take(3).toList();
    _options = [...distractors, _currentEntry!.targetTerm];
    _options.shuffle();
    _correctOption = _options.indexOf(_currentEntry!.targetTerm);

    _selectedOption = null;
    _isAnswered = false;
    _isSubmitting = false;
  }

  Future<void> _checkAnswer() async {
    if (_selectedOption == null || _isSubmitting || _currentEntry == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _isAnswered = true;
    });

    final isCorrect = _selectedOption == _correctOption;
    final rating = isCorrect ? 3 : 1;

    try {
      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: _currentEntry!.id,
        rating: rating,
        sourceIso: _currentEntry!.sourceLocale,
        targetIso: _currentEntry!.targetLocale,
      );
    } finally {
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              if (_entries.isNotEmpty) {
                _prepareQuestion();
              } else {
                _currentEntry = null;
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEntry == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تمرين القواعد'),
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

    final textDir =
        LanguageBiDiHelper.getDirection(_currentEntry!.targetLocale);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تمرين القواعد'),
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
                Text(
                  'اختر الترجمة أو المصطلح الصحيح:',
                  style: AppTypography.title
                      .copyWith(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                AppBaseGlassCard(
                  gradient: AppGradients.purpleCard,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Directionality(
                      textDirection: LanguageBiDiHelper.getDirection(
                          _currentEntry!.sourceLocale),
                      child: Text(
                        _currentEntry!.sourceMeaning,
                        style: AppTypography.display
                            .copyWith(color: Colors.white, fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(_options.length, (index) {
                  final isSelected = _selectedOption == index;
                  final isCorrect = _isAnswered && index == _correctOption;
                  final isWrong =
                      _isAnswered && isSelected && index != _correctOption;

                  Gradient? customGrad;
                  if (isCorrect) {
                    customGrad = const LinearGradient(
                        colors: [Color(0xFF065F46), Color(0xFF047857)]);
                  } else if (isWrong) {
                    customGrad = const LinearGradient(
                        colors: [Color(0xFF991B1B), Color(0xFFB91C1C)]);
                  } else if (isSelected) {
                    customGrad = const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)]);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppBaseGlassCard(
                      onTap: _isAnswered
                          ? null
                          : () => setState(() => _selectedOption = index),
                      gradient: customGrad,
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            child: Text('${index + 1}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Directionality(
                              textDirection: textDir,
                              child: Text(
                                _options[index],
                                style: AppTypography.title.copyWith(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                ElevatedButton(
                  onPressed:
                      (_selectedOption == null || _isSubmitting || _isAnswered)
                          ? null
                          : _checkAnswer,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('تحقق من الإجابة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
