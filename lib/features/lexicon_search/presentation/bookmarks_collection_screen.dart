import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/lexicon_search_notifier.dart';
import '../domain/lexicon_models.dart';
import 'widgets/lexicon_result_card.dart';

class BookmarksCollectionScreen extends StatefulWidget {
  const BookmarksCollectionScreen({
    required this.notifier,
    this.onReviewWord,
    super.key,
  });

  final LexiconSearchNotifier notifier;
  final ValueChanged<SearchResultItem>? onReviewWord;

  @override
  State<BookmarksCollectionScreen> createState() =>
      _BookmarksCollectionScreenState();
}

class _BookmarksCollectionScreenState
    extends State<BookmarksCollectionScreen> {
  String? _selectedCollection;

  @override
  void initState() {
    super.initState();
    widget.notifier.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final state = widget.notifier.state;
        final collections = state.bookmarks
            .expand((bookmark) => bookmark.collections)
            .toSet()
            .toList(growable: false)
          ..sort();
        final bookmarks = _selectedCollection == null
            ? state.bookmarks
            : state.bookmarks
                .where((bookmark) =>
                    bookmark.collections.contains(_selectedCollection))
                .toList(growable: false);

        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          appBar: AppBar(
            title: const Text('المفضلة والملاحظات'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: AppGlassCard(
                    glowColor: AppColors.achievement,
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.collections_bookmark_rounded,
                          color: AppColors.achievement,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${state.bookmarks.length} كلمة محفوظة',
                            style: AppTypography.title,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (collections.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 7),
                          child: ChoiceChip(
                            label: const Text('الكل'),
                            selected: _selectedCollection == null,
                            onSelected: (_) =>
                                setState(() => _selectedCollection = null),
                          ),
                        ),
                        for (final collection in collections)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 7),
                            child: ChoiceChip(
                              label: Text(collection),
                              selected: _selectedCollection == collection,
                              onSelected: (_) => setState(
                                () => _selectedCollection = collection,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (state.isLoadingUserData)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: bookmarks.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد كلمات محفوظة في هذه المجموعة.',
                            style: AppTypography.body,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: bookmarks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final bookmark = bookmarks[index];
                            final item = state.bookmarkItems[bookmark.wordId];
                            if (item == null) return const SizedBox.shrink();
                            return Column(
                              children: <Widget>[
                                LexiconResultCard(
                                  item: item,
                                  isBookmarked: true,
                                  note: state.notes[item.wordId],
                                  onTap: widget.onReviewWord == null
                                      ? null
                                      : () => widget.onReviewWord!(item),
                                  onBookmarkToggle: () =>
                                      widget.notifier.toggleBookmark(item),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton.icon(
                                      onPressed: () =>
                                          _editCollections(bookmark),
                                      icon: const Icon(Icons.folder_rounded),
                                      label: const Text('تصنيف'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _editNote(
                                        item,
                                        state.notes[item.wordId],
                                      ),
                                      icon: const Icon(Icons.edit_note_rounded),
                                      label: const Text('ملاحظة'),
                                    ),
                                    if (widget.onReviewWord != null)
                                      TextButton.icon(
                                        onPressed: () =>
                                            widget.onReviewWord!(item),
                                        icon: const Icon(Icons.bolt_rounded),
                                        label: const Text('مراجعة'),
                                      ),
                                  ],
                                ),
                              ],
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

  Future<void> _editCollections(UserBookmark bookmark) async {
    final controller = TextEditingController(
      text: bookmark.collections.join('، '),
    );
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تصنيف الكلمة'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'مثال: سفر، أفعال مهمة',
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
    final collections = value
        .split(RegExp(r'[,،]'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    await widget.notifier.updateCollections(bookmark.wordId, collections);
  }

  Future<void> _editNote(
    SearchResultItem item,
    WordPersonalNote? current,
  ) async {
    final noteController = TextEditingController(text: current?.note ?? '');
    final examplesController = TextEditingController(
      text: current?.examples.join('\n') ?? '',
    );
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ملاحظة على ${item.germanWord}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: noteController,
                minLines: 2,
                maxLines: 5,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'ملاحظتك',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: examplesController,
                minLines: 2,
                maxLines: 5,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'أمثلة خاصة — مثال في كل سطر',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (save == true) {
      await widget.notifier.saveNote(
        item.wordId,
        noteController.text,
        examples: examplesController.text.split('\n'),
      );
    }
    noteController.dispose();
    examplesController.dispose();
  }
}
