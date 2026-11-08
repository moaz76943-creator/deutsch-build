part of '../learning_pages.dart';
class VocabularyV35 extends StatefulWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final VoidCallback onDone;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final AppDependencies dependencies;
  const VocabularyV35({
    super.key,
    required this.repo,
    required this.corpus,
    required this.onDone,
    required this.presentation,
    required this.contentQuality,
    required this.textNormalizer,
    required this.dependencies,
  });
  @override
  State<VocabularyV35> createState() => _VocabularyV35State();
}
class _VocabularyV35State extends State<VocabularyV35> {
  Set<String> _favorites = {};
  List<Map<String, dynamic>> _customEntries = [];
  String _filter = 'all';
  ViewMode _viewMode = ViewMode.list;
  final PageController _pageController = PageController();
  String get _targetLanguageCode {
    final locale = widget.dependencies.languagePack.targetLocale.trim();
    return locale.isEmpty ? 'de' : locale;
  }
  @override
  void initState() {
    super.initState();
    // // _loadViewMode();
    _loadData();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Future<void> _loadData() async {
    _viewMode =
        UiPreferences(widget.dependencies.preferencesService).viewMode ??
            ViewMode.list;
    final favs = await widget.dependencies.favoritesRepository.getFavorites();
    final langCode =
        widget.presentation.targetLanguageName.contains("لمان") ? "de" : "en";
    final custom = await widget.dependencies.userVocabularyService
        .getCustomEntries(targetLanguage: langCode);
    if (mounted) {
      setState(() {
        _favorites = favs;
        _customEntries = custom;
      });
    }
  }
  Future<void> _setViewMode(ViewMode mode) async {
    setState(() => _viewMode = mode);
    await UiPreferences(
      widget.dependencies.preferencesService,
    ).setViewMode(mode);
  }
  void _speakSource(ContentItem item) {
    unawaited(
      widget.dependencies.audioRuntime
          .play(
            AudioRequest(
              text: item.sourceText,
              languageCode: widget.dependencies.languagePack.targetLocale,
              conceptId: item.id,
            ),
          )
          .then<void>((_) {}),
    );
  }
  void _speakCustomEntry(Map<String, dynamic> entry) {
    final text = entry['german_text']?.toString().trim() ?? '';
    final id = entry['id']?.toString().trim() ?? '';
    if (text.isEmpty || id.isEmpty) return;
    unawaited(
      widget.dependencies.audioRuntime
          .play(
            AudioRequest(
              text: text,
              languageCode: widget.dependencies.languagePack.targetLocale,
              conceptId: id,
            ),
          )
          .then<void>((_) {}),
    );
  }
  Future<void> _openLearningSession(
    BuildContext context,
    ContentItem item,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SingleItemSession(
          repo: widget.repo,
          item: item,
          onDone: widget.onDone,
          presentation: widget.presentation,
          textNormalizer: widget.textNormalizer,
        ),
      ),
    );
  }
  void _showAddCustomDialog() {
    final germanController = TextEditingController();
    final arabicController = TextEditingController();
    final articleController = TextEditingController();
    final notesController = TextEditingController();
    final exampleController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(c).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'إضافة مفردة مخصصة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: germanController,
                  decoration: const InputDecoration(
                    labelText: 'الكلمة بالألمانية',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: arabicController,
                  decoration: const InputDecoration(
                    labelText: 'الترجمة العربية',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: 'none',
                  decoration: const InputDecoration(
                    labelText: 'الأداة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('بدون أداة')),
                    DropdownMenuItem(value: 'der', child: Text('der')),
                    DropdownMenuItem(value: 'die', child: Text('die')),
                    DropdownMenuItem(value: 'das', child: Text('das')),
                  ],
                  onChanged: (v) =>
                      articleController.text = v == 'none' ? '' : v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: exampleController,
                  decoration: const InputDecoration(
                    labelText: 'مثال (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await widget.dependencies.userVocabularyService
                          .addCustomEntry({
                        'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        'german_text': germanController.text,
                        'arabic_translation': arabicController.text,
                        'article': articleController.text,
                        'notes': notesController.text,
                        'example_sentence': exampleController.text,
                        'created_at': DateTime.now().toIso8601String(),
                        'is_custom': 1,
                      });
                      if (mounted) {
                        Navigator.pop(c);
                        _loadData();
                      }
                    }
                  },
                  child: const Text('حفظ'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Color _getArticleColor(String article) {
    switch (article.trim().toLowerCase()) {
      case 'der':
        return const Color(0xFF2563EB);
      case 'die':
        return const Color(0xFFDC2626);
      case 'das':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF7C3AED);
    }
  }
  double _glassOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? .38 : .72;
  Widget _buildListView(List<ContentItem> items) {
    final showTranslation = widget
        .dependencies.settingsController.preferences.showAutomaticTranslation;
    return ListView.separated(
      cacheExtent: 600,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final depth = depthFor(item);
        final issues = widget.contentQuality.issues(item);
        final isFavorite = _favorites.contains(item.id);
        final articleColor = _getArticleColor(item.grammaticalMarker);
        final hasArticle = item.grammaticalMarker.trim().isNotEmpty;
        final scheme = Theme.of(context).colorScheme;
        return AppGlassCard(
          backgroundColor: scheme.surface,
          opacity: _glassOpacity(context),
          borderColor: hasArticle
              ? articleColor.withAlpha(135)
              : scheme.outlineVariant.withAlpha(90),
          glowColor: hasArticle ? articleColor : null,
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding:
                const EdgeInsetsDirectional.fromSTEB(14, 6, 10, 6),
            childrenPadding:
                const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            title: Row(
              children: <Widget>[
                if (hasArticle) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: articleColor.withAlpha(24),
                      border: Border.all(color: articleColor.withAlpha(150)),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      item.grammaticalMarker,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.label.copyWith(
                        color: articleColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: AppDirectionalText(
                    item.sourceText,
                    languageCode: _targetLanguageCode,
                    style: AppTypography.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                AppAudioButton(
                  onPressed: () => _speakSource(item),
                  semanticLabel: 'استمع إلى ${item.sourceText}',
                  activeColor: articleColor,
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'إزالة من المفضلة'
                      : 'إضافة للمفضلة',
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? const Color(0xFFE11D48) : null,
                  ),
                  onPressed: () async {
                    await widget.dependencies.favoritesRepository
                        .toggleFavorite(item.id);
                    await _loadData();
                  },
                ),
              ],
            ),
            subtitle: showTranslation
                ? AppDirectionalText(
                    '${item.translationText} • ${item.topic}',
                    languageCode: 'ar',
                    style: AppTypography.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : AppDirectionalText(
                    item.topic,
                    languageCode: 'ar',
                    style: AppTypography.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            children: <Widget>[
              if (item.exampleText.trim().isNotEmpty)
                ListTile(
                  title: AppDirectionalText(
                    item.exampleText,
                    languageCode: _targetLanguageCode,
                    style: AppTypography.body,
                  ),
                  subtitle: item.exampleTranslationText.trim().isEmpty
                      ? null
                      : AppDirectionalText(
                          item.exampleTranslationText,
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                ),
              if (hasArticle)
                ListTile(
                  title: AppDirectionalText(
                    '${widget.presentation.grammaticalMarkerLabel}: '
                    '${item.grammaticalMarker}',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                  subtitle: item.pluralForm.trim().isEmpty
                      ? null
                      : AppDirectionalText(
                          '${widget.presentation.pluralLabel}: '
                          '${item.pluralForm}',
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                ),
              if (depth.collocation.trim().isNotEmpty)
                ListTile(
                  title: Text('تركيب طبيعي', style: AppTypography.label),
                  subtitle: AppDirectionalText(
                    depth.collocation,
                    languageCode: _targetLanguageCode,
                    style: AppTypography.body,
                  ),
                ),
              if (depth.grammar.trim().isNotEmpty)
                ListTile(
                  title: Text('قاعدة مرتبطة', style: AppTypography.label),
                  subtitle: AppDirectionalText(
                    depth.grammar,
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                ),
              if (issues.isNotEmpty)
                ListTile(
                  title: Text('ملاحظات الجودة', style: AppTypography.label),
                  subtitle: AppDirectionalText(
                    issues.join(' • '),
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => unawaited(
                    _openLearningSession(context, item),
                  ),
                  icon: const Icon(Icons.school_outlined),
                  label: Text(
                    'تدرب واحفظ التقدم',
                    style: AppTypography.label,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildGridView(List<ContentItem> items) {
    final showTranslation = widget
        .dependencies.settingsController.preferences.showAutomaticTranslation;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 620
                ? 3
                : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns >= 3 ? .90 : .72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isFavorite = _favorites.contains(item.id);
            final articleColor = _getArticleColor(item.grammaticalMarker);
            final hasArticle = item.grammaticalMarker.trim().isNotEmpty;
            final scheme = Theme.of(context).colorScheme;
            return AppGlassCard(
              onTap: () => unawaited(_openLearningSession(context, item)),
              backgroundColor: scheme.surface,
              opacity: _glassOpacity(context),
              borderColor: hasArticle
                  ? articleColor.withAlpha(135)
                  : scheme.outlineVariant.withAlpha(90),
              glowColor: hasArticle ? articleColor : null,
              padding: const EdgeInsets.all(13),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (hasArticle)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: articleColor.withAlpha(24),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: articleColor.withAlpha(140),
                            ),
                          ),
                          child: Text(
                            item.grammaticalMarker,
                            textDirection: TextDirection.ltr,
                            style: AppTypography.label.copyWith(
                              color: articleColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const Spacer(),
                      IconButton(
                        tooltip: isFavorite
                            ? 'إزالة من المفضلة'
                            : 'إضافة للمفضلة',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 20,
                          color: isFavorite
                              ? const Color(0xFFE11D48)
                              : scheme.onSurfaceVariant,
                        ),
                        onPressed: () async {
                          await widget.dependencies.favoritesRepository
                              .toggleFavorite(item.id);
                          await _loadData();
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppDirectionalText(
                    item.sourceText,
                    languageCode: _targetLanguageCode,
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(fontSize: 19),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showTranslation) ...<Widget>[
                    const SizedBox(height: 8),
                    AppDirectionalText(
                      item.translationText,
                      languageCode: 'ar',
                      textAlign: TextAlign.center,
                      style: AppTypography.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  AppDirectionalText(
                    item.topic,
                    languageCode: 'ar',
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  AppAudioButton(
                    onPressed: () => _speakSource(item),
                    semanticLabel: 'استمع إلى ${item.sourceText}',
                    activeColor: articleColor,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildFlashcardView(List<ContentItem> items) {
    return PageView.builder(
      controller: _pageController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _FlashcardWidget(
          item: item,
          isFav: _favorites.contains(item.id),
          onToggleFav: () async {
            await widget.dependencies.favoritesRepository
                .toggleFavorite(item.id);
            await _loadData();
          },
          onSpeak: () => _speakSource(item),
          onLearn: () => unawaited(_openLearningSession(context, item)),
          articleColor: _getArticleColor(item.grammaticalMarker),
          targetLanguageCode: _targetLanguageCode,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'A1 • ${widget.corpus.length} وحدات تعلم',
            style: AppTypography.title,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'all',
                          label: Text('الكل', style: AppTypography.label),
                        ),
                        ButtonSegment<String>(
                          value: 'favorites',
                          label: Text('المفضلة', style: AppTypography.label),
                        ),
                        ButtonSegment<String>(
                          value: 'custom',
                          label: Text('مخصص', style: AppTypography.label),
                        ),
                      ],
                      selected: <String>{_filter},
                      onSelectionChanged: (selection) {
                        setState(() => _filter = selection.first);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<ViewMode>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<ViewMode>>[
                      ButtonSegment<ViewMode>(
                        value: ViewMode.list,
                        icon: Icon(Icons.view_list_outlined),
                      ),
                      ButtonSegment<ViewMode>(
                        value: ViewMode.grid,
                        icon: Icon(Icons.grid_view_outlined),
                      ),
                      ButtonSegment<ViewMode>(
                        value: ViewMode.flashcard,
                        icon: Icon(Icons.style_outlined),
                      ),
                    ],
                    selected: <ViewMode>{_viewMode},
                    onSelectionChanged: (selection) {
                      unawaited(_setViewMode(selection.first));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'إضافة مفردة مخصصة',
          onPressed: _showAddCustomDialog,
          child: const Icon(Icons.add_rounded),
        ),
        body: ListenableBuilder(
          listenable: widget.dependencies.settingsController,
          builder: (context, _) {
            final showTranslation = widget.dependencies.settingsController
                .preferences.showAutomaticTranslation;
            if (_filter == 'custom') {
              if (_customEntries.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد مفردات مخصصة بعد.',
                    style: AppTypography.body,
                  ),
                );
              }
              return ListView.separated(
                cacheExtent: 600,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                itemCount: _customEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = _customEntries[index];
                  final id = entry['id']?.toString().trim() ?? '';
                  final german =
                      entry['german_text']?.toString().trim() ?? '';
                  final arabic =
                      entry['arabic_translation']?.toString().trim() ?? '';
                  final article =
                      entry['article']?.toString().trim() ?? '';
                  final articleColor = _getArticleColor(article);
                  final scheme = Theme.of(context).colorScheme;
                  return AppGlassCard(
                    backgroundColor: scheme.surface,
                    opacity: _glassOpacity(context),
                    borderColor: article.isEmpty
                        ? scheme.outlineVariant.withAlpha(90)
                        : articleColor.withAlpha(135),
                    glowColor: article.isEmpty ? null : articleColor,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      14, 12, 10, 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        if (article.isNotEmpty) ...<Widget>[
                          Text(
                            article,
                            textDirection: TextDirection.ltr,
                            style: AppTypography.label.copyWith(
                              color: articleColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AppDirectionalText(
                                german,
                                languageCode: _targetLanguageCode,
                                style: AppTypography.title,
                              ),
                              if (showTranslation && arabic.isNotEmpty)
                                AppDirectionalText(
                                  arabic,
                                  languageCode: 'ar',
                                  style: AppTypography.body,
                                ),
                            ],
                          ),
                        ),
                        if (german.isNotEmpty)
                          AppAudioButton(
                            onPressed: () => _speakCustomEntry(entry),
                            semanticLabel: 'استمع إلى $german',
                            activeColor: articleColor,
                          ),
                        IconButton(
                          tooltip: 'حذف المفردة',
                          onPressed: id.isEmpty
                              ? null
                              : () async {
                                  await widget.dependencies
                                      .userVocabularyService
                                      .deleteCustomEntry(id);
                                  await _loadData();
                                },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            final displayList = _filter == 'favorites'
                ? widget.corpus
                    .where((item) => _favorites.contains(item.id))
                    .toList(growable: false)
                : widget.corpus;
            if (displayList.isEmpty) {
              return Center(
                child: Text('القائمة فارغة.', style: AppTypography.body),
              );
            }
            return switch (_viewMode) {
              ViewMode.list => _buildListView(displayList),
              ViewMode.grid => _buildGridView(displayList),
              ViewMode.flashcard => _buildFlashcardView(displayList),
            };
          },
        ),
      ),
    );
  }
}
class _FlashcardWidget extends StatefulWidget {
  final ContentItem item;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onSpeak;
  final VoidCallback onLearn;
  final Color articleColor;
  final String targetLanguageCode;
  const _FlashcardWidget({
    required this.item,
    required this.isFav,
    required this.onToggleFav,
    required this.onSpeak,
    required this.onLearn,
    required this.articleColor,
    required this.targetLanguageCode,
  });
  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}
class _FlashcardWidgetState extends State<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      unawaited(_controller.forward());
    } else {
      unawaited(_controller.reverse());
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final angle = _animation.value * math.pi;
            final isBackVisible = angle > math.pi / 2;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0012)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isBackVisible
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _buildCardBack(context),
                    )
                  : _buildCardFront(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasArticle = widget.item.grammaticalMarker.trim().isNotEmpty;
    return AppGlassCard(
      backgroundColor: scheme.surface,
      opacity: Theme.of(context).brightness == Brightness.dark ? .38 : .72,
      borderColor: hasArticle
          ? widget.articleColor.withAlpha(150)
          : scheme.outlineVariant.withAlpha(90),
      glowColor: hasArticle ? widget.articleColor : null,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                tooltip:
                    widget.isFav ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                icon: Icon(
                  widget.isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: widget.isFav ? const Color(0xFFE11D48) : null,
                ),
                onPressed: widget.onToggleFav,
              ),
              const Spacer(),
              AppAudioButton(
                onPressed: widget.onSpeak,
                semanticLabel: 'استمع إلى ${widget.item.sourceText}',
                activeColor: widget.articleColor,
              ),
            ],
          ),
          const Spacer(),
          if (hasArticle) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: widget.articleColor.withAlpha(24),
                border: Border.all(
                  color: widget.articleColor.withAlpha(160),
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.item.grammaticalMarker,
                textDirection: TextDirection.ltr,
                style: AppTypography.title.copyWith(
                  color: widget.articleColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          AppDirectionalText(
            widget.item.sourceText,
            languageCode: widget.targetLanguageCode,
            textAlign: TextAlign.center,
            style: AppTypography.display.copyWith(fontSize: 36),
          ),
          const Spacer(),
          AppDirectionalText(
            'اضغط لقلب البطاقة',
            languageCode: 'ar',
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppGlassCard(
      backgroundColor: scheme.surface,
      opacity: Theme.of(context).brightness == Brightness.dark ? .38 : .72,
      borderColor: scheme.outlineVariant.withAlpha(105),
      glowColor: scheme.secondary,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          const Spacer(),
          AppDirectionalText(
            widget.item.translationText,
            languageCode: 'ar',
            textAlign: TextAlign.center,
            style: AppTypography.display.copyWith(fontSize: 28),
          ),
          if (widget.item.pluralForm.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            AppDirectionalText(
              widget.item.pluralForm,
              languageCode: widget.targetLanguageCode,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (widget.item.exampleText.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 28),
            AppDirectionalText(
              widget.item.exampleText,
              languageCode: widget.targetLanguageCode,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(fontSize: 18),
            ),
            if (widget.item.exampleTranslationText.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              AppDirectionalText(
                widget.item.exampleTranslationText,
                languageCode: 'ar',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onLearn,
              icon: const Icon(Icons.school_outlined),
              label: Text(
                'تدرب واحفظ التقدم',
                style: AppTypography.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
