import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/design_system.dart';
import 'sentence_engine.dart';
import 'sentence_models.dart';
import 'sentence_tts.dart';

abstract final class _SentenceUiTokens {
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double tokenGap = 8;
  static const double sheetInset = 18;
}

final class InteractiveSentenceCard extends StatefulWidget {
  const InteractiveSentenceCard({
    required this.sentence,
    required this.engine,
    this.audioController,
    this.onCopied,
    super.key,
  });

  final SentenceEntry sentence;
  final SentenceAnalysisEngine engine;
  final AudioPlaybackController? audioController;
  final ValueChanged<String>? onCopied;

  @override
  State<InteractiveSentenceCard> createState() =>
      _InteractiveSentenceCardState();
}

final class _InteractiveSentenceCardState
    extends State<InteractiveSentenceCard> {
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    widget.audioController?.addListener(_onAudioStateChanged);
  }

  @override
  void didUpdateWidget(covariant InteractiveSentenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioController != widget.audioController) {
      oldWidget.audioController?.removeListener(_onAudioStateChanged);
      widget.audioController?.addListener(_onAudioStateChanged);
    }
  }

  @override
  void dispose() {
    widget.audioController?.removeListener(_onAudioStateChanged);
    super.dispose();
  }

  void _onAudioStateChanged(AudioPlaybackSnapshot _) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.engine.analyze(widget.sentence);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      bottom: false,
      left: false,
      right: false,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: AppGlassCard(
          glowColor: AppColors.primary,
          borderColor: AppColors.primary,
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ActionRow(
                translationVisible: _showTranslation,
                audioController: widget.audioController,
                onToggleTranslation: () {
                  setState(() {
                    _showTranslation = !_showTranslation;
                  });
                },
                onCopy: _copySentence,
                onTogglePlayback: _togglePlayback,
                onShowGrammar: _showGrammarBreakdown,
              ),
              const SizedBox(height: _SentenceUiTokens.sectionGap),
              AppDirectionalText(
                widget.sentence.german,
                languageCode: 'de',
                style: AppTypography.title,
              ),
              if (_showTranslation) ...<Widget>[
                const SizedBox(height: _SentenceUiTokens.contentGap),
                AppDirectionalText(
                  widget.sentence.translationAr,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
              const SizedBox(height: _SentenceUiTokens.sectionGap),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Wrap(
                  spacing: _SentenceUiTokens.tokenGap,
                  runSpacing: _SentenceUiTokens.tokenGap,
                  children: <Widget>[
                    for (final token in tokens) _buildToken(context, token),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToken(BuildContext context, SentenceToken token) {
    if (token.isPunctuation) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _SentenceUiTokens.tokenGap,
        ),
        child: AppDirectionalText(
          token.text,
          languageCode: 'de',
          style: AppTypography.body,
        ),
      );
    }

    final accent = _grammarAccent(token);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      key: ValueKey<String>('sentence-token-${token.index}'),
      onPressed: () => _showTokenInspector(token),
      side: BorderSide(color: accent),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      label: AppDirectionalText(
        token.text,
        languageCode: 'de',
        style: token.lexeme == null
            ? AppTypography.body
            : AppTypography.label.copyWith(color: accent),
      ),
    );
  }

  Color _grammarAccent(SentenceToken token) {
    if (token.verb != null) return AppColors.primary;
    if (token.noun != null) {
      return switch (token.noun!.article) {
        GermanArticle.der => AppColors.articleDer,
        GermanArticle.die => AppColors.articleDie,
        GermanArticle.das => AppColors.articleDas,
      };
    }
    return AppColors.secondary;
  }

  Future<void> _copySentence() async {
    await Clipboard.setData(ClipboardData(text: widget.sentence.german));
    widget.onCopied?.call(widget.sentence.german);
  }

  Future<void> _togglePlayback() async {
    final controller = widget.audioController;
    if (controller == null || !controller.isAvailable) return;

    if (controller.state == AudioPlaybackState.playing) {
      await controller.stop();
      return;
    }

    await controller.play(widget.sentence.german, languageCode: 'de-DE');
  }

  Future<void> _showTokenInspector(SentenceToken token) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_SentenceUiTokens.sheetInset),
              child: AppGlassCard(
                glowColor: _grammarAccent(token),
                borderColor: _grammarAccent(token),
                child: _TokenInspector(
                  token: token,
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _showGrammarBreakdown() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_SentenceUiTokens.sheetInset),
            child: GrammarBreakdownSheet(
              sentence: widget.sentence,
              pattern: widget.engine.detectWordOrderPattern(widget.sentence),
              onClose: () => Navigator.of(sheetContext).pop(),
            ),
          ),
        ),
      );
}

final class GrammarBreakdownSheet extends StatelessWidget {
  const GrammarBreakdownSheet({
    required this.sentence,
    required this.pattern,
    this.onClose,
    super.key,
  });

  final SentenceEntry sentence;
  final SentenceWordOrderPattern pattern;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppGlassCard(
          glowColor: AppColors.secondary,
          borderColor: AppColors.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SheetHeader(
                title: 'تحليل ترتيب الجملة',
                languageCode: 'ar',
                onClose: onClose,
              ),
              const SizedBox(height: _SentenceUiTokens.contentGap),
              ExpansionTile(
                key: const ValueKey<String>('sentence-word-order-rule'),
                initiallyExpanded: true,
                title: AppDirectionalText(
                  pattern.labelDe,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
                children: <Widget>[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppDirectionalText(
                      pattern.explanationAr,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                key: const ValueKey<String>('sentence-grammar-segments'),
                initiallyExpanded: true,
                title: AppDirectionalText(
                  'مكوّنات الجملة',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
                children: sentence.syntaxBreakdown.isEmpty
                    ? <Widget>[
                        const _DetailLine(
                          text: 'لا يوجد تحليل نحوي مخزن لهذه الجملة.',
                          languageCode: 'ar',
                        ),
                      ]
                    : <Widget>[
                        for (final segment in sentence.syntaxBreakdown)
                          _SyntaxSegmentLine(segment: segment),
                      ],
              ),
            ],
          ),
        ),
      );
}

final class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.translationVisible,
    required this.audioController,
    required this.onToggleTranslation,
    required this.onCopy,
    required this.onTogglePlayback,
    required this.onShowGrammar,
  });

  final bool translationVisible;
  final AudioPlaybackController? audioController;
  final VoidCallback onToggleTranslation;
  final Future<void> Function() onCopy;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function() onShowGrammar;

  @override
  Widget build(BuildContext context) {
    final controller = audioController;
    final snapshot = controller?.snapshot;
    final audioEnabled = controller?.isAvailable ?? false;

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: _SentenceUiTokens.tokenGap,
      runSpacing: _SentenceUiTokens.tokenGap,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        IconButton(
          key: const ValueKey<String>('sentence-translation-toggle'),
          tooltip:
              translationVisible ? 'إخفاء الترجمة' : 'إظهار الترجمة',
          onPressed: onToggleTranslation,
          icon: Icon(
            translationVisible
                ? Icons.visibility_off_outlined
                : Icons.translate_outlined,
          ),
        ),
        IconButton(
          key: const ValueKey<String>('sentence-copy-button'),
          tooltip: 'نسخ الجملة',
          onPressed: () async => onCopy(),
          icon: const Icon(Icons.copy_outlined),
        ),
        IconButton(
          key: const ValueKey<String>('sentence-tts-button'),
          tooltip: snapshot?.isPlaying == true ? 'إيقاف الصوت' : 'تشغيل الصوت',
          onPressed: audioEnabled ? () async => onTogglePlayback() : null,
          icon: Icon(
            snapshot?.isPlaying == true
                ? Icons.stop_circle_outlined
                : Icons.volume_up_outlined,
          ),
        ),
        TextButton(
          key: const ValueKey<String>('sentence-speed-toggle'),
          onPressed: audioEnabled ? controller!.toggleSpeed : null,
          child: Text(snapshot?.speed.label ?? AudioPlaybackSpeed.normal.label),
        ),
        TextButton.icon(
          key: const ValueKey<String>('sentence-syntax-button'),
          onPressed: () async => onShowGrammar(),
          icon: const Icon(Icons.account_tree_outlined),
          label: AppDirectionalText(
            'تحليل الجملة',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ),
        if (snapshot != null)
          AppDirectionalText(
            snapshot.state.labelAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
      ],
    );
  }
}

final class _TokenInspector extends StatelessWidget {
  const _TokenInspector({
    required this.token,
    required this.onClose,
  });

  final SentenceToken token;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final lexeme = token.lexeme;
    final noun = token.noun;
    final verb = token.verb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SheetHeader(
          title: lexeme?.lemma ?? token.text,
          languageCode: 'de',
          onClose: onClose,
        ),
        const SizedBox(height: _SentenceUiTokens.sectionGap),
        if (verb != null) ...<Widget>[
          _DetailLine(text: 'Präsens: ${verb.present}', languageCode: 'de'),
          _DetailLine(
            text: 'Präteritum: ${verb.preterite}',
            languageCode: 'de',
          ),
          _DetailLine(text: 'Perfekt: ${verb.perfect}', languageCode: 'de'),
          if (verb.prepositions.isNotEmpty)
            _DetailLine(
              text: 'Präpositionen: ${verb.prepositions.join(', ')}',
              languageCode: 'de',
            ),
        ] else if (noun != null) ...<Widget>[
          _DetailLine(text: noun.article.label, languageCode: 'de'),
          _DetailLine(text: 'Plural: ${noun.plural}', languageCode: 'de'),
          _DetailLine(
            text: 'Kasus: ${noun.grammaticalCase.labelDe}',
            languageCode: 'de',
          ),
        ] else
          const _DetailLine(
            text: 'لا توجد بيانات صرفية إضافية لهذه الكلمة.',
            languageCode: 'ar',
          ),
        if (lexeme?.syntaxRoleDe != null) ...<Widget>[
          const SizedBox(height: _SentenceUiTokens.contentGap),
          _DetailLine(
            text: 'Syntax: ${lexeme!.syntaxRoleDe}',
            languageCode: 'de',
          ),
        ],
        if (lexeme?.syntaxRoleAr != null)
          _DetailLine(
            text: lexeme!.syntaxRoleAr!,
            languageCode: 'ar',
          ),
      ],
    );
  }
}

final class _SyntaxSegmentLine extends StatelessWidget {
  const _SyntaxSegmentLine({required this.segment});

  final SyntaxSegment segment;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: _SentenceUiTokens.contentGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              segment.labelAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              segment.labelDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              segment.text,
              languageCode: 'de',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.languageCode,
    required this.onClose,
  });

  final String title;
  final String languageCode;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: AppDirectionalText(
              title,
              languageCode: languageCode,
              style: AppTypography.title,
            ),
          ),
          if (onClose != null)
            IconButton(
              key: const ValueKey<String>('sentence-sheet-close'),
              tooltip: 'إغلاق',
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
        ],
      );
}

final class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.text,
    required this.languageCode,
  });

  final String text;
  final String languageCode;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: _SentenceUiTokens.tokenGap),
        child: AppDirectionalText(
          text,
          languageCode: languageCode,
          style: AppTypography.body,
        ),
      );
}

@Deprecated('Use InteractiveSentenceCard instead.')
final class SentenceCard extends StatefulWidget {
  const SentenceCard({
    required this.sentence,
    required this.engine,
    this.ttsHook,
    this.onCopied,
    super.key,
  });

  final SentenceEntry sentence;
  final SentenceAnalysisEngine engine;
  final SentenceTtsHook? ttsHook;
  final ValueChanged<String>? onCopied;

  @override
  State<SentenceCard> createState() => _SentenceCardState();
}

final class _SentenceCardState extends State<SentenceCard> {
  AudioPlaybackController? _controller;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant SentenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ttsHook != widget.ttsHook) _syncController();
  }

  void _syncController() {
    final hook = widget.ttsHook;
    _controller = hook == null ? null : AudioPlaybackController(hook: hook);
  }

  @override
  Widget build(BuildContext context) => InteractiveSentenceCard(
        sentence: widget.sentence,
        engine: widget.engine,
        audioController: _controller,
        onCopied: widget.onCopied,
      );
}
