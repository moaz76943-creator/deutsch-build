import 'package:deutsch_bilarabi/services/trie_search_engine.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../design_system/design_system.dart';
// import 'word_deep_dive_sheet.dart';
import 'articles_matrix_screen.dart';
import 'verb_conjugation_screen.dart';
import '../services/database_service.dart';

class OfflineDictionaryScreen extends StatefulWidget {
  const OfflineDictionaryScreen({super.key});

  @override
  State<OfflineDictionaryScreen> createState() => _OfflineDictionaryScreenState();
}

class _OfflineDictionaryScreenState extends State<OfflineDictionaryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
<<<<<<< HEAD
    final epoch = ++_requestEpoch;
    final query = _searchController.text.trim();
    // Preserve actual glyphs (ä/ö/ü/ß) for trigram matching. Expanding
    // umlauts to ae/oe/ue before SQL hides exact lexicon entries.
    final searchTerm = query;
    final lang = ref.read(activeLanguageCodeProvider);
    final selectedLevel = _selectedLevel;
    final selectedArticle = _selectedArticle;

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      List<Map<String, dynamic>> found;
      String? resolvedLemma;
      List<String> suggestions = const <String>[];
      if (selectedLevel == VocabularyCefrFilter.all) {
        try {
          // Handles FTS5-unavailable packs and short queries internally.
          final outcome = await _ftsSearch.searchDictionaryWithFeedback(
            searchTerm,
            lang,
            limit: 50,
          );
          found = outcome.results;
          resolvedLemma = outcome.resolvedLemma;
          suggestions = outcome.suggestions;
        } catch (_) {
          // Retain the pre-FTS dictionary path for legacy installations.
          found = await DatabaseService.instance.searchDictionary(
            searchTerm,
            lang,
          );
        }
      } else {
        // CEFR is applied in SQLite before pagination, not to FTS's first
        // page of results (which could conceal matching vocabulary).
        final outcome = await _cefrSearch.searchWithFeedback(
          languageCode: lang,
          level: selectedLevel,
          searchText: searchTerm,
          limit: 100,
        );
        found = outcome.results.map(_hydrateRow).toList(growable: false);
        resolvedLemma = outcome.resolvedLemma;
        suggestions = outcome.suggestions;
=======
    setState(() => _isLoading = true);
    try {
      // جلب البيانات الحقيقية من قاعدة البيانات
      final normalizedQuery = TrieSearchEngine.normalizeUniversal(_searchQuery);
    final results = await DatabaseService.instance.searchDictionary(
      normalizedQuery.isEmpty ? _searchQuery : normalizedQuery,
      'de',
    );

      List<Map<String, dynamic>> filtered = results;
      if (['der', 'die', 'das'].contains(_selectedFilter)) {
        filtered = results.where((w) => w['article'] == _selectedFilter).toList();
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      }

      setState(() {
<<<<<<< HEAD
        _resolvedLemma = resolvedLemma;
        _suggestions = suggestions;
        _results = selectedArticle == 'الكل'
            ? found
            : found
                .where(
                  (row) => row['article']?.toString() == selectedArticle,
                )
                .toList(growable: false);
        _loading = false;
      });
    } catch (error) {
      if (!mounted || epoch != _requestEpoch) return;
      setState(() {
        _error = 'تعذّر تحميل نتائج المعجم';
        _resolvedLemma = null;
        _suggestions = const <String>[];
        _results = <Map<String, dynamic>>[];
        _loading = false;
=======
        _searchResults = filtered;
        _isLoading = false;
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void onSearchChanged(String val) {
    setState(() => _searchQuery = val);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // تأخير بسيط عشان ما يبحث مع كل حرف بنكتبه (بيخفف الضغط)
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    ref.listen<String>(activeLanguageCodeProvider, (previous, next) {
      if (previous != next) unawaited(_loadData());
    });
    final languageCode = ref.watch(activeLanguageCodeProvider);
    final showKeyboardBar =
        _searchFocus.hasFocus && MediaQuery.of(context).viewInsets.bottom > 0;

=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
<<<<<<< HEAD
                      Row(
                        children: <Widget>[
                          Text(
                            'المعجم الفوري',
                            style: AppTypography.display.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.table_chart_rounded,
                              color: Color(0xFF38BDF8),
                            ),
                            tooltip: 'مصفوفة الأدوات',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ArticlesMatrixScreen(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFFF39C6B),
                            ),
                            tooltip: 'القواعد والأفعال',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VerbConjugationScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن كلمة أو ترجمة...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CefrFilterBar(
                        selected: _selectedLevel,
                        onChanged: (level) {
                          setState(() => _selectedLevel = level);
                          unawaited(_loadData());
                        },
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            for (final option in <String>[
                              'الكل',
                              'der',
                              'die',
                              'das',
                            ])
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ChoiceChip(
                                  label: Text(option),
                                  selected: _selectedArticle == option,
                                  onSelected: (_) {
                                    setState(() => _selectedArticle = option);
                                    unawaited(_loadData());
                                  },
                                ),
                              ),
                          ],
                        ),
=======
                      Text(
                        'المعجم الألماني الفوري',
                        style: AppTypography.display.copyWith(color: Colors.white, fontSize: 22),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.table_chart_rounded, color: Color(0xFF38BDF8)),
                        tooltip: 'مصفوفة الأدوات',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesMatrixScreen())),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_book_rounded, color: Color(0xFFF39C6B)),
                        tooltip: 'القواعد والأفعال',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerbConjugationScreen())),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن كلمة ألمانية أو عربية...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['الكل', 'der', 'die', 'das'].map((f) {
                        final isSel = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
            label: Text(f),
                            selected: isSel,
                            onSelected: (_) {
                              setState(() => _selectedFilter = f);
                              _loadData();
                            },
                          ),
<<<<<<< HEAD
                        )
                      : _error != null
                          ? Center(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            )
                          : _results.isEmpty
                              ? Center(
                                  child: Text(
                                    'لم نجد نتائج مطابقة',
                                    style: AppTypography.body.copyWith(
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.fromLTRB(
                                    20,
                                    8,
                                    20,
                                    showKeyboardBar ? 80 : 96,
                                  ),
                                  itemCount: _results.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = _results[index];
                                    final article =
                                        item['article']?.toString() ?? '';
                                    final word = item['lemma']?.toString() ??
                                        item['surface']?.toString() ??
                                        '';
                                    final meaning =
                                        item['translation_ar']?.toString() ??
                                            'بدون ترجمة';
                                    return AppBaseGlassCard(
                                      onTap: () =>
                                          detail.WordDeepDiveSheet.show(
                                        context,
                                        wordData: item,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          if (article.isNotEmpty)
                                            detail.ArticleBadge(
                                              article: article,
                                            ),
                                          if (article.isNotEmpty)
                                            const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  word,
                                                  style: AppTypography.title
                                                      .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  meaning,
                                                  style: AppTypography.body
                                                      .copyWith(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white24,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
            if (showKeyboardBar)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SpecialCharacterBar(
                  controller: _searchController,
                  languageCode: languageCode,
                ),
=======
                        );
                      }).toList(),
                    ),
                  ),
                ],
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
              ),
            ),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'لم نجد نتائج مطابقة',
                        style: AppTypography.body.copyWith(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final item = _searchResults[idx];
                        final article = item['article'] ?? '';
                        final word = item['lemma'] ?? '';
                        final plural = item['plural'] ?? '-';
                        final meaning = item['translation_ar'] ?? 'بدون ترجمة';
                        final example = item['sentence'] ?? 'بدون مثال';

                        return AppBaseGlassCard(
                          onTap: () {
                            WordDeepDiveSheet.show(
                              context,
                              article: article.isEmpty ? '?' : article,
                              word: word,
                              plural: plural,
                              meaning: meaning,
                              example: example,
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              if (article.isNotEmpty)
                                ArticleBadge(article: article)
                              else
                                const SizedBox(width: 40), // مسافة إذا مافي أداة
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      word,
                                      style: AppTypography.title.copyWith(color: Colors.white, fontSize: 17),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      meaning,
                                      style: AppTypography.body.copyWith(
                                        color: Colors.white.withValues(alpha: 0.75),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    )
  }
}

class WordDeepDiveSheet extends StatelessWidget {
  void show(BuildContext context, {required String article, required String word, required String plural, required String meaning, required String example}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WordDeepDiveSheet(wordData: {'article': article, 'word': word, 'plural': plural, 'meaning': meaning, 'example': example}),
    );
  }

  final Map<String, dynamic> wordData;
  const WordDeepDiveSheet({super.key, required this.wordData});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class ArticleBadge extends StatelessWidget {
  final String article;
  const ArticleBadge({super.key, required this.article});

  @override
  Widget build(BuildContext context) => const SizedBox();
}
