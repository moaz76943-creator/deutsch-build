import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/design_system.dart';
import 'sentence_engine.dart';
import 'sentence_models.dart';
import 'sentence_tts.dart';

abstract final class _SentenceUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double tokenGap = 8;
  static const double sheetInset = 18;
  static const double tokenRadius = 18;
}

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
  bool _showTranslation = false;

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
                ttsEnabled: widget.ttsHook?.isOfflineReady ?? false,
                onToggleTranslation: () {
                  setState(() {
                    _showTranslation = !_showTranslation;
                  });
                },
                onCopy: _copySentence,
                onSpeak: _speakSentence,
                onShowSyntax: _showSyntaxBreakdown,
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
                    for (final token in tokens) _buildToken(token),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToken(SentenceToken token) {
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

    return InkWell(
      key: ValueKey<String>('sentence-token-${token.index}'),
      borderRadius: BorderRadius.circular(_SentenceUiTokens.tokenRadius),
      onTap: () => _showTokenInspector(token),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _SentenceUiTokens.contentGap,
          vertical: _SentenceUiTokens.tokenGap,
        ),
        child: AppDirectionalText(
          token.text,
          languageCode: 'de',
          style: AppTypography.body.copyWith(
            fontWeight: token.lexeme == null
                ? FontWeight.w500
                : FontWeight.w800,
            color: token.lexeme == null
                ? null
                : _grammarAccent(token),
          ),
        ),
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

  Future<void> _speakSentence() async {
    final hook = widget.ttsHook;
    if (hook == null || !hook.isOfflineReady) return;
    await hook.speak(widget.sentence.german, languageCode: 'de-DE');
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

  Future<void> _showSyntaxBreakdown() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_SentenceUiTokens.sheetInset),
              child: AppGlassCard(
                glowColor: AppColors.secondary,
                borderColor: AppColors.secondary,
                child: _SyntaxBreakdown(
                  segments: widget.sentence.syntaxBreakdown,
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ),
          ),
        ),
      );
}

final class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.translationVisible,
    required this.ttsEnabled,
    required this.onToggleTranslation,
    required this.onCopy,
    required this.onSpeak,
    required this.onShowSyntax,
  });

  final bool translationVisible;
  final bool ttsEnabled;
  final VoidCallback onToggleTranslation;
  final Future<void> Function() onCopy;
  final Future<void> Function() onSpeak;
  final Future<void> Function() onShowSyntax;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.start,
        spacing: _SentenceUiTokens.tokenGap,
        runSpacing: _SentenceUiTokens.tokenGap,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          IconButton(
            key: const ValueKey<String>('sentence-translation-toggle'),
            tooltip: translationVisible
                ? 'إخفاء الترجمة'
                : 'إظهار الترجمة',
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
            tooltip: 'نطق محلي',
            onPressed: ttsEnabled ? () async => onSpeak() : null,
            icon: const Icon(Icons.volume_up_outlined),
          ),
          TextButton.icon(
            key: const ValueKey<String>('sentence-syntax-button'),
            onPressed: () async => onShowSyntax(),
            icon: const Icon(Icons.account_tree_outlined),
            label: AppDirectionalText(
              'تحليل الجملة',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ),
        ],
      );
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

final class _SyntaxBreakdown extends StatelessWidget {
  const _SyntaxBreakdown({
    required this.segments,
    required this.onClose,
  });

  final List<SyntaxSegment> segments;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SheetHeader(
            title: 'Syntax · Satzbau',
            languageCode: 'de',
            onClose: onClose,
          ),
          const SizedBox(height: _SentenceUiTokens.sectionGap),
          if (segments.isEmpty)
            const _DetailLine(
              text: 'لا يوجد تحليل نحوي مخزن لهذه الجملة.',
              languageCode: 'ar',
            )
          else
            for (final segment in segments) ...<Widget>[
              AppDirectionalText(
                segment.labelDe,
                languageCode: 'de',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                segment.labelAr,
                languageCode: 'ar',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                segment.text,
                languageCode: 'de',
                style: AppTypography.body,
              ),
              const SizedBox(height: _SentenceUiTokens.contentGap),
            ],
        ],
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
  final VoidCallback onClose;

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
        padding: const EdgeInsets.only(
          bottom: _SentenceUiTokens.tokenGap,
        ),
        child: AppDirectionalText(
          text,
          languageCode: languageCode,
          style: AppTypography.body,
        ),
      );
}
