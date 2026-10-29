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
      }

      setState(() {
        _searchResults = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // تأخير بسيط عشان ما يبحث مع كل حرف بنكتبه (بيخفف الضغط)
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: _onSearchChanged,
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
                        );
                      }).toList(),
                    ),
                  ),
                ],
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
    );
  }
}

class WordDeepDiveSheet extends StatelessWidget {
  static void show(BuildContext context, {required String article, required String word, required String plural, required String meaning, required String example}) {
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
