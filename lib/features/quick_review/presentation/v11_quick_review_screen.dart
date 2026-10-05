import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/content_contract.dart';
import '../../../core/explainer/explainer.dart';
import '../../../core/quick_review/quick_review.dart';
import '../../../design_system/app_audio_button.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../../../features/audio/hybrid_pronunciation_service.dart';
import '../../../features/daily_drill/domain/daily_drill_repository.dart';

class V11QuickReviewScreen extends StatefulWidget {
  const V11QuickReviewScreen({
    required this.session,
    required this.reviewSink,
    required this.pronunciationAudio,
    required this.explainerService,
    required this.sourceLanguageCode,
    required this.translationLanguageCode,
    super.key,
  });

  final QuickReviewSession session;
  final DailyDrillReviewSink reviewSink;
  final HybridPronunciationService pronunciationAudio;
  final ExplainerService explainerService;
  final String sourceLanguageCode;
  final String translationLanguageCode;

  @override
  State<V11QuickReviewScreen> createState() => _V11QuickReviewScreenState();
}

class _V11QuickReviewScreenState extends State<V11QuickReviewScreen> {
  int _index = 0;
  int _correct = 0;
  int _currentStreak = 0;
  int _sessionXp = 0;
  bool _revealed = false;
  bool _busy = false;
  bool _audioBusy = false;
  bool _explanationBusy = false;
  ExplainerResult? _explanation;
  DateTime _cardStartedAt = DateTime.now();

  QuickReviewCard? get _current {
    if (widget.session.isEmpty ||
        _index < 0 ||
        _index >= widget.session.cards.length) {
      return null;
    }
    return widget.session.cards[_index];
  }

  bool get _completed =>
      widget.session.isEmpty || _index >= widget.session.cards.length;

  Future<void> _playCurrent() async {
    final card = _current;
    if (card == null || _busy || _audioBusy) return;
    setState(() => _audioBusy = true);
    try {
      final result = await widget.pronunciationAudio.play(
        conceptId: card.contentId,
        text: card.sourceText,
        languageCode: widget.sourceLanguageCode,
      );
      if (!mounted || result.played) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppDirectionalText(
            'الصوت المحلي غير متاح: ${result.reason ?? 'unknown'}',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _audioBusy = false);
      }
    }
  }

  void _reveal() {
    if (_busy || _revealed || _current == null) return;
    setState(() => _revealed = true);
  }

  Future<void> _explainCurrent() async {
    final card = _current;
    if (card == null || _explanationBusy) return;
    setState(() => _explanationBusy = true);
    try {
      final result = await widget.explainerService.explainWhy(
        ExplainerRequest(contentId: card.contentId),
      );
      if (!mounted) return;
      setState(() {
        _explanation = result;
        _explanationBusy = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _explanationBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppDirectionalText(
            'تعذر تحميل الشرح المحلي لهذه البطاقة.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ),
      );
    }
  }

  Future<void> _grade(bool correct) async {
    final card = _current;
    if (card == null || _busy || !_revealed) return;

    setState(() => _busy = true);
    final elapsed = DateTime.now().difference(_cardStartedAt);
    try {
      final receipt = await widget.reviewSink.record(
        item: _QuickReviewLearningContent(card),
        correct: correct,
        seconds: elapsed.inSeconds.clamp(1, 3600).toInt(),
      );
      if (!mounted) return;
      setState(() {
        if (correct) _correct += 1;
        _currentStreak = receipt.currentStreak;
        _sessionXp = receipt.sessionXp;
        _index += 1;
        _revealed = false;
        _busy = false;
        _explanation = null;
        _cardStartedAt = DateTime.now();
      });
    } on Object {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppDirectionalText(
            'تعذر حفظ المراجعة الآن. لم يتم تجاوز البطاقة.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'المراجعة السريعة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: _completed ? _completion() : _activeReview(),
          ),
        ),
      );

  Widget _activeReview() {
    final card = _current!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: <Widget>[
        _header(),
        const SizedBox(height: 14),
        AppGlassCard(
          glowColor: _articleColor(card.grammaticalMarker),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (card.grammaticalMarker.trim().isNotEmpty)
                AppDirectionalText(
                  card.grammaticalMarker,
                  languageCode: widget.sourceLanguageCode,
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(
                    color: _articleColor(card.grammaticalMarker),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              const SizedBox(height: 10),
              AppDirectionalText(
                card.sourceText,
                languageCode: widget.sourceLanguageCode,
                textAlign: TextAlign.center,
                style: AppTypography.display,
              ),
              const SizedBox(height: 14),
              Center(
                child: AppAudioButton(
                  key: const Key('quick-review-audio'),
                  onPressed:
                      _busy || _audioBusy ? null : () => unawaited(_playCurrent()),
                  semanticLabel: 'استمع إلى المفردة الألمانية',
                  isBusy: _audioBusy,
                  activeColor: _articleColor(card.grammaticalMarker),
                ),
              ),
              const SizedBox(height: 10),
              if (!_revealed)
                FilledButton.icon(
                  key: const Key('quick-review-reveal'),
                  onPressed: _busy ? null : _reveal,
                  icon: const Icon(Icons.visibility_rounded),
                  label: AppDirectionalText(
                    'إظهار الإجابة',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                )
              else ...<Widget>[
                const Divider(),
                const SizedBox(height: 10),
                AppDirectionalText(
                  card.translationText,
                  languageCode: widget.translationLanguageCode,
                  textAlign: TextAlign.center,
                  style: AppTypography.title,
                ),
                if (card.exampleText.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  AppDirectionalText(
                    card.exampleText,
                    languageCode: widget.sourceLanguageCode,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (card.exampleTranslationText.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  AppDirectionalText(
                    card.exampleTranslationText,
                    languageCode: widget.translationLanguageCode,
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ],
                if (card.pluralForm.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AppDirectionalText(
                        'الجمع:',
                        languageCode: 'ar',
                        style: AppTypography.label,
                      ),
                      const SizedBox(width: 6),
                      AppDirectionalText(
                        card.pluralForm,
                        languageCode: widget.sourceLanguageCode,
                        style: AppTypography.label,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  key: const Key('quick-review-explain'),
                  onPressed: _explanationBusy
                      ? null
                      : () => unawaited(_explainCurrent()),
                  icon: _explanationBusy
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lightbulb_outline_rounded),
                  label: AppDirectionalText(
                    'لماذا؟',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_explanation != null) ...<Widget>[
          const SizedBox(height: 12),
          _ExplanationCard(
            result: _explanation!,
            sourceLanguageCode: widget.sourceLanguageCode,
            translationLanguageCode: widget.translationLanguageCode,
          ),
        ],
        if (_revealed) ...<Widget>[
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('quick-review-forgot'),
                  onPressed: _busy ? null : () => unawaited(_grade(false)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: AppDirectionalText(
                    'نسيت',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('quick-review-remembered'),
                  onPressed: _busy ? null : () => unawaited(_grade(true)),
                  icon: const Icon(Icons.check_rounded),
                  label: AppDirectionalText(
                    'تذكرت',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _header() {
    final total = widget.session.cards.length;
    final current = (_index + 1).clamp(1, total);
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(72),
      child: Row(
        children: <Widget>[
          Expanded(
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : current / total,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          AppDirectionalText(
            '$current/$total',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }

  Widget _completion() {
    if (widget.session.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppDirectionalText(
            'لا توجد بطاقات مراجعة مستحقة الآن.',
            languageCode: 'ar',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AppGlassCard(
          glowColor: AppColors.mastery,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.task_alt_rounded, size: 52),
              const SizedBox(height: 12),
              AppDirectionalText(
                'اكتملت المراجعة',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              AppDirectionalText(
                'صحيح $_correct/${widget.session.length} · '
                'السلسلة $_currentStreak · XP $_sessionXp',
                languageCode: 'ar',
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _articleColor(String raw) => switch (raw.trim().toLowerCase()) {
        'der' => AppColors.articleDer,
        'die' => AppColors.articleDie,
        'das' => AppColors.articleDas,
        _ => AppColors.articleOther,
      };
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.result,
    required this.sourceLanguageCode,
    required this.translationLanguageCode,
  });

  final ExplainerResult result;
  final String sourceLanguageCode;
  final String translationLanguageCode;

  @override
  Widget build(BuildContext context) {
    if (!result.found ||
        (result.explanationText.isEmpty && result.facts.isEmpty)) {
      return AppGlassCard(
        key: const Key('quick-review-explanation-card'),
        child: AppDirectionalText(
          'لا يوجد شرح محلي موثّق إضافي لهذه البطاقة.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return AppGlassCard(
      key: const Key('quick-review-explanation-card'),
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'لماذا؟',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: 8),
          if (result.explanationText.isNotEmpty) ...<Widget>[
            AppDirectionalText(
              result.explanationText,
              key: const Key('quick-review-reason-text'),
              languageCode: translationLanguageCode,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (result.facts.isNotEmpty) const SizedBox(height: 10),
          ],
          for (final fact in result.facts) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppDirectionalText(
                  '${_label(fact.kind)}:',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AppDirectionalText(
                    fact.value,
                    languageCode: _factLanguageCode(fact.kind),
                    style: AppTypography.body,
                  ),
                ),
              ],
            ),
            if (fact.evidence.isNotEmpty)
              AppDirectionalText(
                fact.evidence.join(' · '),
                languageCode: _factLanguageCode(fact.kind),
                style: AppTypography.label,
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  String _factLanguageCode(ExplainerFactKind kind) => switch (kind) {
        ExplainerFactKind.meaning => translationLanguageCode,
        _ => sourceLanguageCode,
      };

  String _label(ExplainerFactKind kind) => switch (kind) {
        ExplainerFactKind.meaning => 'المعنى',
        ExplainerFactKind.grammaticalMarker => 'الأداة',
        ExplainerFactKind.pluralForm => 'الجمع',
        ExplainerFactKind.usageExample => 'مثال',
        ExplainerFactKind.verbAgreement => 'التصريف',
        ExplainerFactKind.pastForm => 'الماضي',
      };
}

final class _QuickReviewLearningContent implements LearningContent {
  _QuickReviewLearningContent(QuickReviewCard card)
      : id = card.contentId,
        sourceText = card.sourceText,
        translationText = card.translationText,
        exampleText = card.exampleText,
        exampleTranslationText = card.exampleTranslationText,
        topic = card.topic,
        skill = card.skill,
        grammaticalMarker = card.grammaticalMarker,
        pluralForm = card.pluralForm,
        acceptedForms = List<String>.unmodifiable(card.acceptedForms);

  @override
  final String id;
  @override
  final String sourceText;
  @override
  final String translationText;
  @override
  final String exampleText;
  @override
  final String exampleTranslationText;
  @override
  final String topic;
  @override
  final String skill;
  @override
  final String grammaticalMarker;
  @override
  final String pluralForm;
  @override
  final List<String> acceptedForms;
}
