import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/search_models.dart';

class SearchResultsListView extends StatelessWidget {
  const SearchResultsListView({
    required this.items,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.emptyMessage = 'لا توجد نتائج مطابقة.',
    super.key,
  });

  final List<SearchResultItem> items;
  final bool Function(String wordId) isFavorite;
  final ValueChanged<SearchResultItem> onFavoriteToggle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _SearchResultCard(
          item: item,
          favorite: isFavorite(item.id),
          onFavoriteToggle: () => onFavoriteToggle(item),
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.item,
    required this.favorite,
    required this.onFavoriteToggle,
  });

  final SearchResultItem item;
  final bool favorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final articleColor = _articleColor(item.article);
    return AppGlassCard(
      glowColor: item.hasArticle ? articleColor : AppColors.primary,
      child: Row(
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
                      const SizedBox(width: 7),
                    ],
                    Expanded(
                      child: Text(
                        item.term,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.title,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    item.translationArabic,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: favorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            onPressed: onFavoriteToggle,
            icon: Icon(
              favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: favorite ? AppColors.achievement : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _articleColor(GermanArticle article) => switch (article) {
        GermanArticle.der => AppColors.articleDer,
        GermanArticle.die => AppColors.articleDie,
        GermanArticle.das => AppColors.articleDas,
        GermanArticle.none => AppColors.articleOther,
      };
}
