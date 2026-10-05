import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/app_audio_button.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart';
import '../../features/audio/domain/entities/audio_request.dart';
import '../../services/app_dependencies.dart';
import '../../services/grammar_hub_service.dart';

class GrammarQuizPage extends StatefulWidget {
  final String topicId;
  final AppDependencies dependencies;

  const GrammarQuizPage({
    Key? key,
    required this.topicId,
    required this.dependencies,
  }) : super(key: key);

  @override
  State<GrammarQuizPage> createState() => _GrammarQuizPageState();
}

class _GrammarQuizPageState extends State<GrammarQuizPage> {
  List<GrammarQuiz> _quizzes = <GrammarQuiz>[];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  int? _selectedIndex;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadQuizzes());
  }

  Future<void> _loadQuizzes() async {
    final quizzes = await widget.dependencies.grammarHubService
        .getQuizzesForTopic(widget.topicId);
    if (!mounted) return;
    setState(() {
      _quizzes = quizzes;
      _isLoading = false;
    });
  }

  void _submitAnswer(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
      if (index == _quizzes[_currentIndex].correctIndex) {
        _correctCount++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < _quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedIndex = null;
      });
      return;
    }

    if (_correctCount == _quizzes.length && _quizzes.isNotEmpty) {
      await widget.dependencies.grammarHubService.saveTopicMastery(
        widget.topicId,
        true,
      );
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _languageCodeFor(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? 'ar' : 'de';

  void _speakQuestion(String text) {
    final value = text.trim();
    if (value.isEmpty || _languageCodeFor(value) != 'de') return;
    unawaited(
      widget.dependencies.audioRuntime
          .play(
            AudioRequest(
              text: value,
              languageCode: widget.dependencies.languagePack.targetLocale,
              conceptId: 'grammar.quiz.${widget.topicId}.${_currentIndex + 1}',
              variant: AudioVariant.sentence,
            ),
          )
          .then<void>((_) {}),
    );
  }

  double _glassOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? .38 : .72;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'اختبار القواعد',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _quizzes.isEmpty
                  ? Center(
                      child: AppDirectionalText(
                        'لا توجد أسئلة متاحة لهذا الموضوع.',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    )
                  : _buildQuizContent(context),
        ),
      );

  Widget _buildQuizContent(BuildContext context) {
    final quiz = _quizzes[_currentIndex];
    final questionLanguage = _languageCodeFor(quiz.question);
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'السؤال ${_currentIndex + 1} من ${_quizzes.length}',
            languageCode: 'ar',
            style: AppTypography.label.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AppGlassCard(
            backgroundColor: scheme.surface,
            opacity: _glassOpacity(context),
            glowColor: AppColors.primary,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AppDirectionalText(
                    quiz.question,
                    languageCode: questionLanguage,
                    style: AppTypography.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (questionLanguage == 'de') ...<Widget>[
                  const SizedBox(width: 10),
                  AppAudioButton(
                    onPressed: () => _speakQuestion(quiz.question),
                    semanticLabel: 'استمع إلى السؤال',
                    activeColor: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...List<Widget>.generate(quiz.options.length, (index) {
            final option = quiz.options[index];
            final isCorrect = index == quiz.correctIndex;
            final isSelected = index == _selectedIndex;
            final accent = !_isAnswered
                ? scheme.outlineVariant
                : isCorrect
                    ? AppColors.mastery
                    : isSelected
                        ? AppColors.tertiary
                        : scheme.outlineVariant;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppGlassCard(
                onTap: _isAnswered ? null : () => _submitAnswer(index),
                backgroundColor: scheme.surface,
                opacity: _glassOpacity(context),
                borderColor: accent.withAlpha(_isAnswered ? 170 : 95),
                glowColor: _isAnswered && (isCorrect || isSelected)
                    ? accent
                    : null,
                child: AppDirectionalText(
                  option,
                  languageCode: _languageCodeFor(option),
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
          if (_isAnswered) ...<Widget>[
            const SizedBox(height: 4),
            AppGlassCard(
              backgroundColor: scheme.surface,
              opacity: _glassOpacity(context),
              glowColor: _selectedIndex == quiz.correctIndex
                  ? AppColors.mastery
                  : AppColors.tertiary,
              child: AppDirectionalText(
                quiz.explanation,
                languageCode: 'ar',
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => unawaited(_nextQuestion()),
              child: AppDirectionalText(
                _currentIndex < _quizzes.length - 1
                    ? 'السؤال التالي'
                    : 'إنهاء',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
