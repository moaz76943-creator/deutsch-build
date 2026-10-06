import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/lexicon_models.dart';

class LexiconResultCard extends StatelessWidget {
  const LexiconResultCard({
    required this.item,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    this.note,
    this.onTap,
    super.key,
  });

  final SearchResultItem item;
  final bool isBookmarked;
  final WordPersonalNote? note;
  final VoidCallback onBookmarkToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final articleColor = _articleColor(item.article);
    return AppGlassCard(
      onTap: onTap,
      glowColor: item.hasArticle ? articleColor : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        if (item.hasArticle) ...<Widget>[
                          Text(
                            item.articleLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(
                              color: articleColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: AppDesignTokens.spaceS),
                        ],
                        Expanded(
                          child: AppDirectionalText(
                            item.germanWord,
                            languageCode: 'de',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.spaceS),
                    AppDirectionalText(
                      item.arabicMeaning,
                      languageCode: 'ar',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDesignTokens.spaceS),
              Column(
                children: <Widget>[
                  if (item.hasCefrLevel)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(22),
                        borderRadius:
                            BorderRadius.circular(AppDesignTokens.radiusM),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesignTokens.spaceS,
                          vertical: AppDesignTokens.spaceS / 2,
                        ),
                        child: Text(
                          item.cefrLevel,
                          style: AppTypography.label.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    tooltip: isBookmarked
                        ? 'إزالة من المفضلة'
                        : 'إضافة إلى المفضلة',
                    onPressed: onBookmarkToggle,
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isBookmarked
                          ? AppColors.achievement
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (note != null &&
              (note!.note.isNotEmpty || note!.examples.isNotEmpty)) ...<Widget>[
            const SizedBox(height: AppDesignTokens.spaceS),
            Divider(color: AppColors.primary.withAlpha(35), height: 1),
            const SizedBox(height: AppDesignTokens.spaceS),
            if (note!.note.isNotEmpty)
              AppDirectionalText(
                note!.note,
                languageCode: 'ar',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            if (note!.examples.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDesignTokens.spaceS / 2),
              AppDirectionalText(
                note!.examples.first,
                languageCode: 'de',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _articleColor(LexiconArticle article) => switch (article) {
        LexiconArticle.der => AppColors.articleDer,
        LexiconArticle.die => AppColors.articleDie,
        LexiconArticle.das => AppColors.articleDas,
        LexiconArticle.none => AppColors.articleOther,
      };
}
