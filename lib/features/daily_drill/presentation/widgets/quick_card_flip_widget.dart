import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/memory.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/daily_drill_models.dart';

class QuickCardFlipWidget extends StatelessWidget {
  const QuickCardFlipWidget({
    required this.review,
    required this.revealed,
    required this.onFlip,
    this.sourceLanguageCode = 'de',
    this.translationLanguageCode = 'ar',
    super.key,
  });

  final FlashcardReviewItem review;
  final bool revealed;
  final VoidCallback? onFlip;
  final String sourceLanguageCode;
  final String translationLanguageCode;

  @override
  Widget build(BuildContext context) {
    final article = review.item.grammaticalMarker.trim().toLowerCase();
    final accent = _articleColor(article);

    return Semantics(
      button: onFlip != null,
      label: revealed ? 'إخفاء معنى البطاقة' : 'إظهار معنى البطاقة',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: revealed ? math.pi : 0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        builder: (context, angle, _) {
          final showBack = angle > math.pi / 2;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, .0012)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Transform(
              alignment: Alignment.center,
              transform: showBack
                  ? (Matrix4.identity()..rotateY(math.pi))
                  : Matrix4.identity(),
              child: AppGlassCard(
                onTap: onFlip,
                blur: 22,
                opacity: .14,
                borderColor: accent.withAlpha(120),
                glowColor: accent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 260),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: showBack
                        ? _CardBack(
                            key: const ValueKey<String>('daily-card-back'),
                            review: review,
                            accent: accent,
                            sourceLanguageCode: sourceLanguageCode,
                            translationLanguageCode: translationLanguageCode,
                          )
                        : _CardFront(
                            key: const ValueKey<String>('daily-card-front'),
                            review: review,
                            article: article,
                            accent: accent,
                            sourceLanguageCode: sourceLanguageCode,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _articleColor(String article) => switch (article) {
        'der' => AppColors.articleDer,
        'die' => AppColors.articleDie,
        'das' => AppColors.articleDas,
        _ => AppColors.articleOther,
      };
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.review,
    required this.article,
    required this.accent,
    required this.sourceLanguageCode,
    super.key,
  });

  final FlashcardReviewItem review;
  final String article;
  final Color accent;
  final String sourceLanguageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (article.isNotEmpty) ...<Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withAlpha(22),
              border: Border.all(color: accent.withAlpha(130)),
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withAlpha(34),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Text(
                article,
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        AppDirectionalText(
          review.item.sourceText,
          languageCode: sourceLanguageCode,
          textAlign: TextAlign.center,
          style: AppTypography.display.copyWith(
            color: accent,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'اضغط لإظهار المعنى والمثال',
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
        const SizedBox(height: 14),
        _MemoryHint(review: review, accent: accent),
      ],
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({
    required this.review,
    required this.accent,
    required this.sourceLanguageCode,
    required this.translationLanguageCode,
    super.key,
  });

  final FlashcardReviewItem review;
  final Color accent;
  final String sourceLanguageCode;
  final String translationLanguageCode;

  @override
  Widget build(BuildContext context) {
    final example = review.item.exampleText.trim();
    final translatedExample = review.item.exampleTranslationText.trim();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppDirectionalText(
            review.item.translationText,
            languageCode: translationLanguageCode,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (example.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            AppDirectionalText(
              example,
              languageCode: sourceLanguageCode,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (translatedExample.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            AppDirectionalText(
              translatedExample,
              languageCode: translationLanguageCode,
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'قيّم تذكرك قبل الانتقال للبطاقة التالية.',
            textAlign: TextAlign.center,
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

class _MemoryHint extends StatelessWidget {
  const _MemoryHint({
    required this.review,
    required this.accent,
  });

  final FlashcardReviewItem review;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final label = switch (review.reviewReason) {
      MemoryReviewReason.overdue => 'متأخرة',
      MemoryReviewReason.lapse => 'تحتاج تثبيتًا',
      MemoryReviewReason.consolidation => 'تثبيت طويل',
      MemoryReviewReason.due => 'مستحقة الآن',
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: accent),
        ),
      ),
    );
  }
}
