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
  // A read-only practice preview: never mutate SRS or learner progress.
  bool _studyMode = false;
  int _cardIndex = 0;
  bool _showAnswer = false;
  bool _quizMode = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quizController = TextEditingController();
  DialogRoute<void>? _detailsRoute;

  // Dismiss the exact open detail route when the selected pair, level or
  // topic changes. Never pop the underlying learning screen by mistake.
  void _dismissStaleDetails() {
    final route = _detailsRoute;
    _detailsRoute = null;
    if (route != null && route.isActive) {
      route.navigator?.removeRoute(route);
    }
  }

  void _resetCardAnswer() {
    _showAnswer = false;
    _quizController.clear();
  }

  // Filter only verified rows returned by the selected directed-pair loader.
  // Arabic vowel marks/tatweel and German sharp-s should not block lookup.
  // Never stringify malformed metadata into a learner-facing translation,
  // article, search result or quiz answer.
  static String? _safeText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static String _displayLevel(Object? value) {
    final level = _safeText(value)?.toUpperCase();
    return const <String>{'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
            .contains(level)
        ? level!
        : 'UNKNOWN';
  }

  static String _foldSearch(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\u0640\u064B-\u065F\u0670]'), '')
      // German digraph input must match both NFC and decomposed umlauts.
      .replaceAll('a\u0308', 'ae')
      .replaceAll('o\u0308', 'oe')
      .replaceAll('u\u0308', 'ue')
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss');

  // A form or example is searchable only when the selected, verified row
  // actually supplies a string. Bound optional arrays to keep malformed or
  // oversized future adapters from turning a 50-row search into a UI stall.
  static bool _listContainsSearch(Object? value, String query) {
    if (value is! List) return false;
    return value.take(32).whereType<String>().any(
          (text) => _foldSearch(text).contains(query),
        );
  }

  List<Map<String, dynamic>> _matchingRows() {
    final query = _foldSearch(_searchQuery);
    if (query.isEmpty) return _rows;
    return _rows.where((row) {
      final headword = "${_safeText(row['article']) ?? ''} ${_safeText(row['word']) ?? ''}";
      final translation = _safeText(row['translation_ar']) ?? '';
      final sense = _safeText(row['sense_gloss']);
      return _foldSearch(headword).contains(query) ||
          _foldSearch(translation).contains(query) ||
          (sense != null && _foldSearch(sense).contains(query)) ||
          _listContainsSearch(row['forms'], query) ||
          _listContainsSearch(row['examples'], query);
    }).toList(growable: false);
  }

  Widget _buildStudyCard(List<Map<String, dynamic>> rows) {
    // Search and request epochs reset the index before rows can change.
    final index = _cardIndex < rows.length ? _cardIndex : 0;
    final row = rows[index];
    final word = _safeText(row['word']) ?? '';
    final article = _safeText(row['article']);
    final translation = _safeText(row['translation_ar']);
    final level = _displayLevel(row['cefr_level']);
    final displayWord = word.isEmpty
        ? 'لا يتوفر نص موثق لهذه المفردة'
        : article == null || article.isEmpty
            ? word
            : '$article $word';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بطاقة ${index + 1} من ${rows.length}',
            key: const Key('study-progress'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            level == 'UNKNOWN'
                ? 'المستوى UNKNOWN — لا يوجد دليل على انتماء هذه المفردة إلى ${widget.cefr}.'
                : 'المستوى حسب الحزمة: $level (ليس اعتماداً مستقلاً).',
            key: const Key('study-cefr-evidence'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'تدريب محلي فقط؛ لا يُحفظ التقدم أو تتغير مراجعات SRS.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const Key('study-quiz-toggle'),
            onPressed: () => setState(() {
              _quizMode = !_quizMode;
              _resetCardAnswer();
            }),
            icon: Icon(_quizMode ? Icons.style_outlined : Icons.edit_note),
            label: Text(_quizMode ? 'العودة للبطاقات' : 'اختبار كتابة الترجمة'),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    displayWord,
                    key: const Key('study-source'),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  if (_quizMode) ...[
                    const Text(
                      'اختبار مراجعة ذاتية: قارن إجابتك بالمحتوى المحلي؛ '
                      'لا يوجد تصحيح آلي أو تسجيل لنتيجة.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (translation != null && translation.isNotEmpty) ...[
                      TextField(
                        key: const Key('study-quiz-input'),
                        controller: _quizController,
                        textDirection: TextDirection.rtl,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() => _showAnswer = false),
                        decoration: const InputDecoration(
                          labelText: 'اكتب الترجمة بالعربية',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_showAnswer)
                        FilledButton(
                          key: const Key('study-quiz-compare'),
                          onPressed: _quizController.text.trim().isEmpty
                              ? null
                              : () => setState(() => _showAnswer = true),
                          child: const Text('قارن بالإجابة المرجعية'),
                        ),
                    ] else
                      const Text(
                        'لا تتوفر إجابة مرجعية لهذه البطاقة؛ '
                        'لا يمكن اختبار الترجمة دون محتوى موثق.',
                        textAlign: TextAlign.center,
                      ),
                  ],
                  if (_showAnswer)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        translation == null || translation.isEmpty
                            ? 'لا توجد ترجمة عربية موثقة لهذا السجل.'
                            : translation,
                        key: const Key('study-answer'),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (!_quizMode)
                    FilledButton(
                      key: const Key('study-reveal'),
                      onPressed: () => setState(() => _showAnswer = true),
                      child: const Text('إظهار الترجمة'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                key: const Key('study-previous'),
                onPressed: index == 0
                    ? null
                    : () => setState(() {
                          _cardIndex = index - 1;
                          _resetCardAnswer();
                        }),
                child: const Text('السابق'),
              ),
              OutlinedButton(
                key: const Key('study-next'),
                onPressed: index + 1 >= rows.length
                    ? null
                    : () => setState(() {
                          _cardIndex = index + 1;
                          _resetCardAnswer();
                        }),
                child: const Text('التالي'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This sheet reads only fields supplied by the selected local row. Missing
  // senses, forms and examples are not generated or borrowed from other pairs.
  void _showWordDetails(Map<String, dynamic> row) {
    List<String> lines(Object? value) => value is List
        ? value.whereType<String>().map((text) => text.trim())
            .where((text) => text.isNotEmpty).toList(growable: false)
        : const <String>[];

    TextDirection direction(String value) => RegExp(
          r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
        ).hasMatch(value)
            ? TextDirection.rtl
            : TextDirection.ltr;

    final word = _safeText(row['word']);
    final article = _safeText(row['article']);
    final displayWord = word == null
        ? 'لا يتوفر نص موثق لهذه المفردة'
        : article == null ? word : '$article $word';
    final translation = _safeText(row['translation_ar']);
    final sense = _safeText(row['sense_gloss']);
    final forms = lines(row['forms']);
    final examples = lines(row['examples']);
    final partOfSpeech = _safeText(row['part_of_speech']);
    final level = _displayLevel(row['cefr_level']);

    Widget detail(String label, List<String> values,
        {TextDirection? textDirection}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            for (final value in values)
              Text(value, textDirection: textDirection ?? direction(value)),
          ],
        ),
      );
    }

    final route = DialogRoute<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تفاصيل المفردة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                detail('الكلمة', [displayWord],
                    textDirection: TextDirection.ltr),
                detail('الترجمة', [
                  translation ?? 'لا توجد ترجمة عربية متاحة في هذا السجل.'
                ], textDirection: TextDirection.rtl),
                detail('المعنى', [
                  sense ?? 'لا يتوفر شرح معنى في هذا السجل.'
                ]),
                detail('الصيغ والتصريفات', forms.isEmpty
                    ? ['لا تتوفر صيغ موثقة في هذا السجل.'] : forms),
                detail('أمثلة الاستخدام', examples.isEmpty
                    ? ['لا تتوفر أمثلة موثقة في هذا السجل.'] : examples),
                if (partOfSpeech != null)
                  detail('نوع الكلمة حسب الحزمة', [partOfSpeech],
                      textDirection: TextDirection.ltr),
                detail('المستوى', [
                  level == 'UNKNOWN'
                      ? 'UNKNOWN — لا يوجد تصنيف مستوى معتمد لهذا السجل.'
                      : 'تصنيف وارد من الحزمة: $level (ليس اعتماداً مستقلاً).'
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
    _detailsRoute = route;
    Navigator.of(context, rootNavigator: true).push(route).whenComplete(() {
      if (identical(_detailsRoute, route)) _detailsRoute = null;
    });
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
      // A dialog opened for the previous selection must never keep displaying
      // another directed pair's translation or an obsolete level's details.
      _dismissStaleDetails();
      // Invalidate pending reads and stale filters on topic/level/pair changes.
      _searchController.clear();
      _searchQuery = '';
      _load();
    }
  }

  @override
  void dispose() {
    _requestId++;
    _searchController.dispose();
    _quizController.dispose();
    super.dispose();
  }

  bool get _supportsDirectedPair =>
      widget.languageCode == 'de' &&
      widget.targetLanguageCode == 'ar' &&
      LocalTopicCatalog.supportsBundledTopics(widget.languageCode);

  // The default SQLite query is already scoped, but injected/alternate pack
  // readers must not leak another directed pair or a different known level.
  // Older de->ar rows can omit target metadata; an explicit mismatch is never
  // treated as a valid translation. Unknown CEFR remains UNKNOWN, not inferred.
  bool _rowBelongsToSelection(Map<String, dynamic> row) {
    final word = row['word'];
    if (word is! String || word.trim().isEmpty) return false;

    bool matchesWhenDeclared(String field, String expected) {
      if (!row.containsKey(field)) return true;
      final value = row[field];
      return value is String &&
          value.trim().toLowerCase() == expected.toLowerCase();
    }

    if (!matchesWhenDeclared('language_code', widget.languageCode) ||
        !matchesWhenDeclared('source_language_code', widget.languageCode) ||
        !matchesWhenDeclared('target_language_code', widget.targetLanguageCode) ||
        !matchesWhenDeclared(
            'translation_language_code', widget.targetLanguageCode)) {
      return false;
    }

    final recordedLevel = row['cefr_level'];
    if (recordedLevel is String) {
      final normalized = recordedLevel.trim().toUpperCase();
      if (const <String>{'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
              .contains(normalized) &&
          normalized != widget.cefr.toUpperCase()) {
        return false;
      }
    }
    return true;
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    if (!_supportsDirectedPair) {
      setState(() {
        _rows = const [];
        _loading = false;
        _failed = false;
        _studyMode = false;
        _quizMode = false;
        _cardIndex = 0;
        _resetCardAnswer();
      });
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
      _rows = const [];
      _studyMode = false;
      _quizMode = false;
      _cardIndex = 0;
      _resetCardAnswer();
    });
    try {
      final loader = widget.loadWords ?? LocalTopicCatalog.loadSection;
      // A stalled local DB/adapter must not trap learners on an infinite
      // spinner. The existing error state offers retry; the request epoch
      // prevents a late result from replacing a newer pair/level selection.
      final rows = await loader(
        sectionId: widget.section.id,
        cefr: widget.cefr,
        languageCode: widget.languageCode,
      ).timeout(const Duration(seconds: 30));
      if (!mounted || requestId != _requestId) return;
      setState(() {
        // The built-in query is bounded to 50. Enforce the same UI bound
        // for injected/future readers before creating cards and search lists.
        _rows = rows.where(_rowBelongsToSelection).take(50).toList(growable: false);
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
          actions: [
            if (_supportsDirectedPair && !_loading && !_failed && _rows.isNotEmpty)
              IconButton(
                key: const Key('topic-study-toggle'),
                tooltip: _studyMode ? 'عرض قائمة المفردات' : 'التدرب بالبطاقات',
                onPressed: () => setState(() {
                  _studyMode = !_studyMode;
                  _quizMode = false;
                  _cardIndex = 0;
                  _resetCardAnswer();
                }),
                icon: Icon(_studyMode ? Icons.list : Icons.style_outlined),
                color: Theme.of(context).colorScheme.onSurface,
              ),
          ],
          bottom: _supportsDirectedPair && !_loading && !_failed && _rows.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(76),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      key: const Key('topic-search'),
                      controller: _searchController,
                      onChanged: (value) => setState(() {
                        _searchQuery = value;
                        _cardIndex = 0;
                        _resetCardAnswer();
                      }),
                      textInputAction: TextInputAction.search,
                      // Keep the caret and entered text in the script's
                      // direction; the surrounding Arabic UI stays RTL.
                      textDirection: RegExp(
                        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
                      ).hasMatch(_searchQuery)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'ابحث بالكلمة أو الترجمة',
                        labelStyle: TextStyle(color: Colors.black54),
                        prefixIcon: Icon(Icons.search, color: Colors.black54),
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
                        : _studyMode
                            ? _buildStudyCard(matchingRows)
                            : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: matchingRows.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final row = matchingRows[index];
                          final word = _safeText(row['word']) ?? '';
                          final article = _safeText(row['article']);
                          final translation = _safeText(row['translation_ar']);
                          final level = _displayLevel(row['cefr_level']);
                          final displayWord = article == null || article.isEmpty
                              ? word
                              : '$article $word';
                          return ListTile(
                            onTap: () => _showWordDetails(row),
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
                            trailing: Tooltip(
                              message: level == 'UNKNOWN'
                                  ? 'المستوى غير موثق؛ لا يُنسب تلقائياً إلى ${widget.cefr}'
                                  : 'تصنيف الحزمة؛ ليس اعتماداً مستقلاً',
                              child: Text(level),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
