import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/lexicon_search_notifier.dart';
import '../domain/lexicon_models.dart';
import 'widgets/lexicon_result_card.dart';

class QuickSearchModal extends StatefulWidget {
  const QuickSearchModal({
    required this.notifier,
    super.key,
  });

  final LexiconSearchNotifier notifier;

  @override
  State<QuickSearchModal> createState() => _QuickSearchModalState();
}

class _QuickSearchModalState extends State<QuickSearchModal> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.notifier.state.query.text);
    widget.notifier.initialize();
    widget.notifier.searchNow();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final state = widget.notifier.state;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppDesignTokens.spaceM,
              AppDesignTokens.spaceM,
              AppDesignTokens.spaceM,
              AppDesignTokens.spaceM +
                  MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: AppGlassCard(
              borderColor: AppColors.primary.withAlpha(70),
              glowColor: AppColors.primary,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'بحث معجمي سريع',
                            style: AppTypography.title,
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.spaceS),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: widget.notifier.updateText,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Deutsch أو العربية…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: state.isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(AppDesignTokens.spaceM),
                                child: SizedBox.square(
                                  dimension: AppDesignTokens.spaceM,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.primary.withAlpha(10),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDesignTokens.radiusM),
                          borderSide: BorderSide(
                            color: AppColors.primary.withAlpha(55),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spaceS),
                    _Filters(notifier: widget.notifier),
                    const SizedBox(height: AppDesignTokens.spaceS),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDesignTokens.spaceS,
                        ),
                        child: AppDirectionalText(
                          'تعذر تنفيذ البحث المحلي.',
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                      ),
                    Flexible(
                      child: state.results.isEmpty && !state.isSearching
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppDesignTokens.spaceL,
                                ),
                                child: Text(
                                  'لا توجد نتائج مطابقة.',
                                  style: AppTypography.body,
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: state.results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(
                                    height: AppDesignTokens.spaceS,
                                  ),
                              itemBuilder: (context, index) {
                                final item = state.results[index];
                                return LexiconResultCard(
                                  item: item,
                                  isBookmarked:
                                      widget.notifier.isBookmarked(item.wordId),
                                  note: widget.notifier.noteFor(item.wordId),
                                  onBookmarkToggle: () =>
                                      widget.notifier.toggleBookmark(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.notifier});

  final LexiconSearchNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final filters = notifier.state.query.filters;
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: AppDesignTokens.spaceS,
        runSpacing: AppDesignTokens.spaceS,
        children: <Widget>[
          _articleChip('der', LexiconArticle.der, AppColors.articleDer, filters),
          _articleChip('die', LexiconArticle.die, AppColors.articleDie, filters),
          _articleChip('das', LexiconArticle.das, AppColors.articleDas, filters),
          for (final level in LexiconSearchFilters.supportedCefrLevels)
            FilterChip(
              label: Text(level, style: AppTypography.label),
              selected: filters.cefrLevels.contains(level),
              onSelected: (_) => notifier.toggleCefrLevel(level),
              selectedColor: AppColors.secondary.withAlpha(24),
            ),
        ],
      ),
    );
  }

  Widget _articleChip(
    String label,
    LexiconArticle article,
    Color color,
    LexiconSearchFilters filters,
  ) {
    final selected = filters.articles.contains(article);
    return FilterChip(
      label: Text(
        label,
        style: AppTypography.label.copyWith(
          color: selected ? color : null,
          fontWeight: FontWeight.w900,
        ),
      ),
      selected: selected,
      onSelected: (_) => notifier.toggleArticle(article),
      selectedColor: color.withAlpha(22),
      side: BorderSide(color: color.withAlpha(selected ? 150 : 60)),
      checkmarkColor: color,
    );
  }
}
