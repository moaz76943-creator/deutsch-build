import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../services/database_service.dart';
import '../services/fts_search_service.dart';
import '../services/trie_search_engine.dart';
import '../services/vocabulary_filter_service.dart';
import '../widgets/cefr_filter_bar.dart';
import '../widgets/special_character_bar.dart';
import 'articles_matrix_screen.dart';
import 'verb_conjugation_screen.dart';
import 'word_deep_dive_sheet.dart' as detail;

class OfflineDictionaryScreen extends StatefulWidget {
  const OfflineDictionaryScreen({super.key});

  @override
  State<OfflineDictionaryScreen> createState() =>
      _OfflineDictionaryScreenState();
}

class _OfflineDictionaryScreenState extends State<OfflineDictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FtsSearchService _ftsSearch = FtsSearchService();
  final VocabularyFilterService _vocabularyFilters = VocabularyFilterService();

  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  VocabularyCefrFilter _cefrLevel = VocabularyCefrFilter.all;
  List<Map<String, dynamic>> _searchResults = <Map<String, dynamic>>[];
  bool _isLoading = true;
  Timer? _debounce;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _searchFocus.addListener(_onFocusChanged);
    _loadData();
  }

  @override
  void dispose() {
    _requestVersion++;
    _debounce?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocus.removeListener(_onFocusChanged);
    _searchFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchTextChanged() {
    final text = _searchController.text;
    if (_searchQuery == text) return;
    setState(() => _searchQuery = text);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _loadData);
  }

  static Map<String, dynamic> _fromFilterRow(Map<String, Object?> row) {
    final raw = row['fields_json'];
    Map<String, dynamic> fields = <String, dynamic>{};
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          fields = decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
      } on FormatException {
        // Malformed optional metadata must not hide the surface form.
      }
    }
    final surface = row['surface']?.toString() ?? '';
    final id = row['id']?.toString() ?? '';
    return <String, dynamic>{
      'id': id,
      'lexeme_id': id,
      'language_code': 'de',
      'surface': surface,
      'lemma': fields['lemma']?.toString() ?? surface,
      'part_of_speech': row['part_of_speech'],
      'article': fields['article'],
      'plural': fields['plural'],
      'translation_ar': fields['translation_ar'] ?? fields['translation'],
      'sentence': fields['sentence'] ?? fields['example'],
      'fields_json': raw,
      'fields': fields,
    };
  }

  Future<void> _loadData() async {
    final request = ++_requestVersion;
    if (mounted) setState(() => _isLoading = true);
    final normalized = TrieSearchEngine.normalizeUniversal(_searchQuery);
    final term = normalized.isEmpty ? _searchQuery : normalized;
    try {
      final List<Map<String, dynamic>> results;
      if (_cefrLevel == VocabularyCefrFilter.all) {
        try {
          results = await _ftsSearch.searchDictionary(term, 'de');
        } catch (_) {
          // Legacy pack or missing FTS capability: retain the old query path.
          results = await DatabaseService.instance.searchDictionary(term, 'de');
        }
      } else {
        final rows = await _vocabularyFilters.search(
          languageCode: 'de',
          level: _cefrLevel,
          query: term,
          limit: 100,
        );
        results = rows.map(_fromFilterRow).toList(growable: false);
      }

      if (!mounted || request != _requestVersion) return;
      setState(() {
        _searchResults = _selectedFilter == 'الكل'
            ? results
            : results
                .where((item) => item['article'] == _selectedFilter)
                .toList(growable: false);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || request != _requestVersion) return;
      debugPrint('Dictionary lookup failed: $error');
      setState(() {
        _searchResults = <Map<String, dynamic>>[];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
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
                      Text(
                        'المعجم الألماني الفوري',
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.table_chart_rounded,
                            color: Color(0xFF38BDF8)),
                        tooltip: 'مصفوفة الأدوات',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArticlesMatrixScreen(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_book_rounded,
                            color: Color(0xFFF39C6B)),
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
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن كلمة ألمانية أو عربية...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                      children: <String>['الكل', 'der', 'die', 'das'].map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: _selectedFilter == f,
                            onSelected: (_) {
                              setState(() => _selectedFilter = f);
                              _loadData();
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CefrFilterBar(
                    selected: _cefrLevel,
                    enabled: !_isLoading,
                    onChanged: (level) {
                      setState(() => _cefrLevel = level);
                      _debounce?.cancel();
                      _loadData();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF38BDF8),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            'لم نجد نتائج مطابقة',
                            style: AppTypography.body.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            final article =
                                item['article']?.toString() ?? '';
                            final word =
                                item['lemma']?.toString() ?? '';
                            final meaning =
                                item['translation_ar']?.toString() ??
                                    'بدون ترجمة';
                            return AppBaseGlassCard(
                              onTap: () => detail.WordDeepDiveSheet.show(
                                context,
                                wordData: item,
                              ),
                              child: Row(
                                children: <Widget>[
                                  if (article.isNotEmpty)
                                    detail.ArticleBadge(article: article)
                                  else
                                    const SizedBox(width: 40),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          word,
                                          style: AppTypography.title.copyWith(
                                            color: Colors.white,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          meaning,
                                          style: AppTypography.body.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
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
            if (_searchFocus.hasFocus && keyboardVisible)
              SpecialCharacterBar(
                controller: _searchController,
                languageCode: 'de',
              ),
          ],
        ),
      ),
    );
  }
}
