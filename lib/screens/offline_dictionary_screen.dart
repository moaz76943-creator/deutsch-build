import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/design_system.dart';
import '../providers/active_language_provider.dart';
import '../services/database_service.dart';
import '../services/fts_search_service.dart';
import '../services/vocabulary_filter_service.dart';
import '../widgets/cefr_filter_bar.dart';
import '../widgets/special_character_bar.dart';
import 'word_deep_dive_sheet.dart' as detail;
import 'articles_matrix_screen.dart';
import 'verb_conjugation_screen.dart';

class OfflineDictionaryScreen extends ConsumerStatefulWidget {
  const OfflineDictionaryScreen({super.key});

  @override
  ConsumerState<OfflineDictionaryScreen> createState() =>
      _OfflineDictionaryScreenState();
}

class _OfflineDictionaryScreenState
    extends ConsumerState<OfflineDictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FtsSearchService _ftsSearch = FtsSearchService();
  final VocabularyFilterService _cefrSearch = VocabularyFilterService();

  String _selectedArticle = 'الكل';
  VocabularyCefrFilter _selectedLevel = VocabularyCefrFilter.all;
  List<Map<String, dynamic>> _results = <Map<String, dynamic>>[];
  String? _resolvedLemma;
  List<String> _suggestions = const <String>[];
  bool _loading = true;
  String? _error;
  Timer? _debounce;
  int _requestEpoch = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onControllerChanged);
    _searchFocus.addListener(_onFocusChanged);
    unawaited(_loadData());
  }

  @override
  void dispose() {
    ++_requestEpoch;
    _debounce?.cancel();
    _searchController.removeListener(_onControllerChanged);
    _searchController.dispose();
    _searchFocus.removeListener(_onFocusChanged);
    _searchFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onControllerChanged() {
    // Programmatic controller updates from SpecialCharacterBar do not call
    // TextField.onChanged. Listening to the controller covers both paths.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_loadData());
    });
  }

  static Map<String, dynamic> _hydrateRow(Map<String, Object?> row) {
    Map<String, dynamic> fields = <String, dynamic>{};
    final source = row['fields_json'];
    if (source is String && source.isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map) {
          fields = decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
      } on FormatException {
        // A malformed optional field does not invalidate the entire result.
      }
    }
    final surface = row['surface']?.toString() ?? '';
    return <String, dynamic>{
      ...row,
      'fields': fields,
      'lemma': fields['lemma']?.toString() ?? surface,
      'article': fields['article'],
      'plural': fields['plural'],
      'translation_ar': fields['translation_ar'] ?? fields['translation'],
      'sentence': fields['sentence'] ?? fields['example'],
    };
  }

  Future<void> _loadData() async {
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
      }

      if (!mounted || epoch != _requestEpoch) return;
      setState(() {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(activeLanguageCodeProvider, (previous, next) {
      if (previous != next) unawaited(_loadData());
    });
    final languageCode = ref.watch(activeLanguageCodeProvider);
    final showKeyboardBar =
        _searchFocus.hasFocus && MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    children: <Widget>[
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
                      ),
                    ],
                  ),
                ),
                if (!_loading &&
                    (_resolvedLemma != null || _suggestions.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        if (_resolvedLemma != null)
                          Chip(label: Text('Results for $_resolvedLemma')),
                        if (_suggestions.isNotEmpty)
                          const Text(
                            'Did you mean?',
                            style: TextStyle(color: Colors.white70),
                          ),
                        for (final spelling in _suggestions)
                          ActionChip(
                            label: Text(spelling),
                            onPressed: () {
                              _searchController.value = TextEditingValue(
                                text: spelling,
                                selection: TextSelection.collapsed(
                                  offset: spelling.length,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF38BDF8),
                          ),
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
              ),
          ],
        ),
      ),
    );
  }
}
