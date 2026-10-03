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
    switch (article.toLowerCase()) {
      case 'der':
        return const Color(0xFF2563EB); // Masculine/Slate Blue
      case 'die':
        return const Color(0xFFE11D48); // Feminine/Soft Crimson
      case 'das':
        return const Color(0xFF0D9488); // Neuter/Deep Teal
      default:
        return const Color(0xFF7C3AED); // Plural/Muted Violet
    }
  }

  Widget _buildListView(List<ContentItem> items) {
    final showTranslation =
        widget.dependencies.settingsController.preferences.showAutomaticTranslation;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (c, i) {
        final x = items[i];
        final d = depthFor(x);
        final issues = widget.contentQuality.issues(x);
        final isFav = _favorites.contains(x.id);
        final color = _getArticleColor(x.grammaticalMarker);

        return Card(
          child: ExpansionTile(
            title: Row(
              children: [
                if (x.grammaticalMarker.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: color),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      x.grammaticalMarker,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    x.sourceText,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_outlined),
                  onPressed: () => _speakSource(x),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () async {
                    await widget.dependencies.favoritesRepository
                        .toggleFavorite(x.id);
                    _loadData();
                  },
                ),
              ],
            ),
            subtitle: Text(
              showTranslation ? '${x.translationText} • ${x.topic}' : x.topic,
            ),
            children: [
              ListTile(
                title: Text(x.exampleText, textDirection: TextDirection.ltr),
                subtitle: Text(x.exampleTranslationText),
              ),
              if (x.grammaticalMarker.isNotEmpty)
                ListTile(
                  title: Text(
                    '${widget.presentation.grammaticalMarkerLabel}: ${x.grammaticalMarker}',
                  ),
                  subtitle: Text(
                    x.pluralForm.isEmpty
                        ? ''
                        : '${widget.presentation.pluralLabel}: ${x.pluralForm}',
                  ),
                ),
              if (d.collocation.isNotEmpty)
                ListTile(
                  title: const Text('تركيب طبيعي'),
                  subtitle: Text(d.collocation),
                ),
              if (d.grammar.isNotEmpty)
                ListTile(
                  title: const Text('قاعدة مرتبطة'),
                  subtitle: Text(d.grammar),
                ),
              if (issues.isNotEmpty)
                ListTile(title: Text('محجوب: ${issues.join(' • ')}')),
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('تدرب من البداية إلى الاحتفاظ'),
                onTap: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                    builder: (_) => SingleItemSession(
                      repo: widget.repo,
                      item: x,
                      onDone: widget.onDone,
                      presentation: widget.presentation,
                      textNormalizer: widget.textNormalizer,
                    ),
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
    final showTranslation =
        widget.dependencies.settingsController.preferences.showAutomaticTranslation;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (c, i) {
        final x = items[i];
        final isFav = _favorites.contains(x.id);
        final color = _getArticleColor(x.grammaticalMarker);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: x.grammaticalMarker.isNotEmpty
                  ? color.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => _speakSource(x),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (x.grammaticalMarker.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            x.grammaticalMarker,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () async {
                          await widget.dependencies.favoritesRepository
                              .toggleFavorite(x.id);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    x.sourceText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  ),
                  if (showTranslation) ...[
                    const SizedBox(height: 8),
                    Text(
                      x.translationText,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  const Icon(
                    Icons.volume_up_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlashcardView(List<ContentItem> items) {
    return PageView.builder(
      controller: _pageController,
      itemCount: items.length,
      itemBuilder: (c, i) {
        return _FlashcardWidget(
          item: items[i],
          isFav: _favorites.contains(items[i].id),
          onToggleFav: () async {
            await widget.dependencies.favoritesRepository.toggleFavorite(
              items[i].id,
            );
            _loadData();
          },
          onSpeak: () => _speakSource(items[i]),
          articleColor: _getArticleColor(items[i].grammaticalMarker),
        );
      },
    );
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A1 • ${widget.corpus.length} وحدات تعلم'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('الكل')),
                      ButtonSegment(value: 'favorites', label: Text('المفضلة')),
                      ButtonSegment(value: 'custom', label: Text('مخصص')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => _filter = newSelection.first);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<ViewMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ViewMode.list,
                      icon: Icon(Icons.view_list_outlined),
                    ),
                    ButtonSegment(
                      value: ViewMode.grid,
                      icon: Icon(Icons.grid_view_outlined),
                    ),
                    ButtonSegment(
                      value: ViewMode.flashcard,
                      icon: Icon(Icons.style_outlined),
                    ),
                  ],
                  selected: {_viewMode},
                  onSelectionChanged: (Set<ViewMode> newSelection) {
                    _setViewMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomDialog,
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: widget.dependencies.settingsController,
        builder: (c, _) {
          final showTranslation = widget.dependencies.settingsController
              .preferences.showAutomaticTranslation;
          if (_filter == 'custom') {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _customEntries.length,
              itemBuilder: (c, i) {
                final e = _customEntries[i];
                return Card(
                  child: ListTile(
                    title: Text(
                      e['german_text'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: showTranslation
                        ? Text(e['arabic_translation'] as String)
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await widget.dependencies.userVocabularyService
                            .deleteCustomEntry(e['id'] as String);
                        _loadData();
                      },
                    ),
                  ),
                );
              },
            );
          }

          final displayList = _filter == 'favorites'
              ? widget.corpus.where((x) => _favorites.contains(x.id)).toList()
              : widget.corpus;

          if (displayList.isEmpty) {
            return const Center(child: Text('القائمة فارغة.'));
          }

          switch (_viewMode) {
            case ViewMode.list:
              return _buildListView(displayList);
            case ViewMode.grid:
              return _buildGridView(displayList);
            case ViewMode.flashcard:
              return _buildFlashcardView(displayList);
          }
        },
      ),
    );
  }
}

class _FlashcardWidget extends StatefulWidget {
  final ContentItem item;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onSpeak;
  final Color articleColor;

  const _FlashcardWidget({
    required this.item,
    required this.isFav,
    required this.onToggleFav,
    required this.onSpeak,
    required this.articleColor,
  });

  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * math.pi;
            final isBackVisible = angle > math.pi / 2;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
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
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: widget.item.grammaticalMarker.isNotEmpty
          ? widget.articleColor.withValues(alpha: 0.05)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    widget.isFav ? Icons.favorite : Icons.favorite_border,
                    color: widget.isFav ? Colors.red : null,
                  ),
                  onPressed: widget.onToggleFav,
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_outlined, size: 28),
                  onPressed: widget.onSpeak,
                ),
              ],
            ),
            const Spacer(),
            if (widget.item.grammaticalMarker.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: widget.articleColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.item.grammaticalMarker,
                  style: TextStyle(
                    color: widget.articleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              widget.item.sourceText,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
            const Spacer(),
            const Text('اضغط للقلب', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            Text(
              widget.item.translationText,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (widget.item.pluralForm.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'الجمع: ${widget.item.pluralForm}',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 32),
            if (widget.item.exampleText.isNotEmpty) ...[
              Text(
                widget.item.exampleText,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.exampleTranslationText,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

