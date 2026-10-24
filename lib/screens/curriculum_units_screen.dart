import 'package:flutter/material.dart';

import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';

/// Read-only topic lookup. Tests may inject a loader without opening SQLite.
typedef TopicWordsLoader = Future<List<Map<String, dynamic>>> Function({
  required String sectionId,
  required String cefr,
  required String languageCode,
});

/// The curriculum lists topics that can be queried from the installed pack.
/// It never invents progress, lesson counts, unlocks, or CEFR assignments.
class CurriculumUnitsScreen extends StatefulWidget {
  const CurriculumUnitsScreen({
    super.key,
    this.languageCode = 'de',
    this.targetLanguageCode = 'ar',
    this.loadWords,
  });

  final String languageCode;
  final String targetLanguageCode;
  final TopicWordsLoader? loadWords;

  @override
  State<CurriculumUnitsScreen> createState() => _CurriculumUnitsScreenState();
}

class _CurriculumUnitsScreenState extends State<CurriculumUnitsScreen> {
  static const _levels = <String>['A1', 'A2', 'B1', 'B2'];
  String _selectedLevel = 'A1';

  @override
  Widget build(BuildContext context) {
    // The bundled topic index only supports the verified de -> ar projection.
    // A registered language or the reverse direction does not imply content.
    final supported = widget.languageCode == 'de' &&
        widget.targetLanguageCode == 'ar' &&
        LocalTopicCatalog.supportsBundledTopics(widget.languageCode);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Text(
                  'الموضوعات والمفردات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'تظهر الكلمات الموجودة فعلاً في قاعدة البيانات المحلية، '
                  'دون تقدّم أو مستويات مفترضة. الاتجاه المتاح: من الألمانية إلى العربية.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final level in _levels)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          key: Key('cefr-$level'),
                          label: Text(level),
                          selected: _selectedLevel == level,
                          onSelected: supported
                              ? (_) => setState(() => _selectedLevel = level)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: !supported
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'لا تتوفر أقسام محلية موثقة لهذا الاتجاه اللغوي حالياً.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                        itemCount: LocalTopicCatalog.sections.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final section = LocalTopicCatalog.sections[index];
                          return Semantics(
                            button: true,
                            label: '${section.title}، المستوى $_selectedLevel',
                            child: AppBaseGlassCard(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => TopicWordsScreen(
                                    section: section,
                                    cefr: _selectedLevel,
                                    languageCode: widget.languageCode,
                                    targetLanguageCode: widget.targetLanguageCode,
                                    loadWords: widget.loadWords,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.menu_book_rounded,
                                      color: Color(0xFF38BDF8)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      section.title,
                                      style: AppTypography.title.copyWith(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_left,
                                      color: Colors.white70),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bounded, read-only view of verified local lexical rows. No fake fallback
/// translations, SRS writes, or cross-language pivoting occur here.
class TopicWordsScreen extends StatefulWidget {
  const TopicWordsScreen({
    super.key,
    required this.section,
    required this.cefr,
    required this.languageCode,
    this.targetLanguageCode = 'ar',
    this.loadWords,
  });

  final LocalTopicSection section;
  final String cefr;
  final String languageCode;
  final String targetLanguageCode;
  final TopicWordsLoader? loadWords;

  @override
  State<TopicWordsScreen> createState() => _TopicWordsScreenState();
}

class _TopicWordsScreenState extends State<TopicWordsScreen> {
  int _requestId = 0;
  bool _loading = true;
  bool _failed = false;
  List<Map<String, dynamic>> _rows = const [];
  String _searchQuery = '';

  // Filter only verified rows returned by the selected directed-pair loader.
  // Arabic vowel marks/tatweel and German sharp-s should not block lookup.
  static String _foldSearch(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\u0640\u064B-\u065F\u0670]'), '')
      .replaceAll('ß', 'ss');

  List<Map<String, dynamic>> _matchingRows() {
    final query = _foldSearch(_searchQuery);
    if (query.isEmpty) return _rows;
    return _rows.where((row) {
      final headword = "${row['article'] ?? ''} ${row['word'] ?? ''}";
      final translation = row['translation_ar']?.toString() ?? '';
      return _foldSearch(headword).contains(query) ||
          _foldSearch(translation).contains(query);
    }).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant TopicWordsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.id != widget.section.id ||
        oldWidget.cefr != widget.cefr ||
        oldWidget.languageCode != widget.languageCode ||
        oldWidget.targetLanguageCode != widget.targetLanguageCode ||
        oldWidget.loadWords != widget.loadWords) {
      // Invalidate pending reads when the user changes topic, level or pair.
      _load();
    }
  }

  @override
  void dispose() {
    _requestId++;
    super.dispose();
  }

  bool get _supportsDirectedPair =>
      widget.languageCode == 'de' &&
      widget.targetLanguageCode == 'ar' &&
      LocalTopicCatalog.supportsBundledTopics(widget.languageCode);

  Future<void> _load() async {
    final requestId = ++_requestId;
    if (!_supportsDirectedPair) {
      setState(() {
        _rows = const [];
        _loading = false;
        _failed = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final loader = widget.loadWords ?? LocalTopicCatalog.loadSection;
      final rows = await loader(
        sectionId: widget.section.id,
        cefr: widget.cefr,
        languageCode: widget.languageCode,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _rows = const [];
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchingRows = _matchingRows();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.section.title} — ${widget.cefr}'),
          bottom: _supportsDirectedPair && !_loading && !_failed && _rows.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(76),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      key: const Key('topic-search'),
                      onChanged: (value) => setState(() => _searchQuery = value),
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        labelText: 'ابحث بالكلمة أو الترجمة',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: !_supportsDirectedPair
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'لا تتوفر مفردات موثقة لهذا الاتجاه اللغوي حالياً.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'تعذر قراءة المحتوى المحلي. لم تتغير بيانات التعلم.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : _rows.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'لا توجد مفردات موثقة لهذا الموضوع والمستوى '
                            'في الحزمة المثبتة.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : matchingRows.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'لا توجد نتائج مطابقة. غيّر عبارة البحث لعرض المفردات المتوفرة.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: matchingRows.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final row = matchingRows[index];
                          final word = (row['word'] ?? '').toString();
                          final article = row['article']?.toString().trim();
                          final translation =
                              row['translation_ar']?.toString().trim();
                          final level = row['cefr_level']?.toString().trim();
                          final displayWord = article == null || article.isEmpty
                              ? word
                              : '$article $word';
                          return ListTile(
                            title: Text(
                              displayWord,
                              textDirection: TextDirection.ltr,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              translation == null || translation.isEmpty
                                  ? 'لا توجد ترجمة عربية موثقة'
                                  : translation,
                              textDirection: TextDirection.rtl,
                            ),
                            trailing: level == null || level.isEmpty
                                ? null
                                : Text(level),
                          );
                        },
                      ),
      ),
    );
  }
}
