import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/bookmarks_notifier.dart';
import '../../domain/search_models.dart';

class FavoritesListScreen extends StatelessWidget {
  const FavoritesListScreen({
    required this.notifier,
    this.onStartQuickPractice,
    super.key,
  });

  final BookmarksNotifier notifier;
  final ValueChanged<List<SearchResultItem>>? onStartQuickPractice;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        final state = notifier.state;
        final items = state.bookmarks.map((bookmark) => bookmark.item).toList();
        return Scaffold(
          appBar: AppBar(title: const Text('المفضلة والملاحظات')),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: AppGlassCard(
                    glowColor: AppColors.achievement,
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.bookmarks_rounded,
                          color: AppColors.achievement,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${items.length} كلمة محفوظة',
                            style: AppTypography.title,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: items.isEmpty || onStartQuickPractice == null
                              ? null
                              : () => onStartQuickPractice!(items),
                          icon: const Icon(Icons.bolt_rounded),
                          label: const Text('تمرين سريع'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'احفظ كلمات من نتائج البحث لتظهر هنا.',
                            style: AppTypography.body,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: state.bookmarks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final bookmark = state.bookmarks[index];
                            final note = state.notes[bookmark.item.id];
                            return _FavoriteCard(
                              bookmark: bookmark,
                              note: note,
                              onRemove: () => notifier.toggle(bookmark.item),
                              onEditNote: () => _editNote(
                                context,
                                bookmark.item,
                                note,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editNote(
    BuildContext context,
    SearchResultItem item,
    CustomWordNote? note,
  ) async {
    final controller = TextEditingController(text: note?.text ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ملاحظة على ${item.term}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظتك الشخصية…',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await notifier.saveNote(item.id, value);
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.bookmark,
    required this.note,
    required this.onRemove,
    required this.onEditNote,
  });

  final UserBookmark bookmark;
  final CustomWordNote? note;
  final VoidCallback onRemove;
  final VoidCallback onEditNote;

  Color _articleColor(GermanArticle article) => switch (article) {
        GermanArticle.der => AppColors.articleDer,
        GermanArticle.die => AppColors.articleDie,
        GermanArticle.das => AppColors.articleDas,
        GermanArticle.none => AppColors.articleOther,
      };

  @override
  Widget build(BuildContext context) {
    final item = bookmark.item;
    return AppGlassCard(
      glowColor: AppColors.achievement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    if (item.hasArticle) ...<Widget>[
                      Text(
                        item.articleLabel,
                        style: AppTypography.label.copyWith(
                          color: _articleColor(item.article),
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
              ),
              IconButton(
                tooltip: 'تعديل الملاحظة',
                onPressed: onEditNote,
                icon: const Icon(Icons.edit_note_rounded),
              ),
              IconButton(
                tooltip: 'إزالة من المفضلة',
                onPressed: onRemove,
                icon: const Icon(Icons.bookmark_remove_rounded),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(item.translationArabic, style: AppTypography.body),
          ),
          if (note != null) ...<Widget>[
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.achievement.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    note!.text,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
