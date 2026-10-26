import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';
String _normalizedLanguageCode(String value) => value.trim().toLowerCase();
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
  Route<void>? _activeTopicRoute;
  // Changing the parent pair (or replacing its reader) must invalidate that
  // route, not leave a stale de->ar page over the new language selection.
  void _dismissStaleTopicRoute() {
    final route = _activeTopicRoute;
    _activeTopicRoute = null;
    if (route == null || !route.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = route.navigator;
      if (route.isActive && navigator != null && navigator.mounted) {
        navigator.removeRoute(route);
      }
    });
  }
  @override
  void didUpdateWidget(covariant CurriculumUnitsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode ||
        oldWidget.targetLanguageCode != widget.targetLanguageCode ||
        oldWidget.loadWords != widget.loadWords) {
      _dismissStaleTopicRoute();
    }
  }
  @override
  void dispose() {
    _dismissStaleTopicRoute();
    super.dispose();
  }
  void _openTopic(LocalTopicSection section) {
    if (_activeTopicRoute?.isActive ?? false) return;
    final selectedLevel = _selectedLevel;
    final sourceLanguage = _normalizedLanguageCode(widget.languageCode);
    final targetLanguage = _normalizedLanguageCode(widget.targetLanguageCode);
    final loader = widget.loadWords;
    final route = MaterialPageRoute<void>(
      builder: (_) => TopicWordsScreen(
        section: section,
        cefr: selectedLevel,
        languageCode: sourceLanguage,
        targetLanguageCode: targetLanguage,
        loadWords: loader,
      ),
    );
    _activeTopicRoute = route;
    Navigator.of(context).push(route).whenComplete(() {
      if (identical(_activeTopicRoute, route)) _activeTopicRoute = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    // The bundled topic index only supports the verified de -> ar projection.
    // A registered language or the reverse direction does not imply content.
    final source = _normalizedLanguageCode(widget.languageCode);
    final target = _normalizedLanguageCode(widget.targetLanguageCode);
    final supported = source == 'de' && target == 'ar' &&
        LocalTopicCatalog.supportsBundledTopics(source);
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
                              onTap: () => _openTopic(section),
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
  bool _staleSnapshot = false;
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
  // Dismiss the exact owned route, not the underlying learning screen.
  // didUpdateWidget runs during a build: mutating the root Navigator there
  // can trigger a build-phase assertion. Defer removal until after the frame.
  void _dismissStaleDetails() {
    final route = _detailsRoute;
    _detailsRoute = null;
    if (route == null || !route.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = route.navigator;
      if (route.isActive && navigator != null && navigator.mounted) {
        navigator.removeRoute(route);
      }
    });
  }
  void _resetCardAnswer() {
    _showAnswer = false;
    _quizController.clear();
  }
  // Never turn malformed metadata into learner-facing lexical content.
  static String? _safeText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty || _foldSearch(text).isEmpty ? null : text;
  }
  static String _displayLevel(Object? value) {
    final level = _safeText(value)?.toUpperCase();
    return const <String>{'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
            .contains(level)
        ? level!
        : 'UNKNOWN';
  }
  // Conflicting or malformed declared CEFR aliases cannot justify a badge.
  static String _rowDisplayLevel(Map<String, dynamic> row) {
    String? level;
    for (final field in const <String>['cefr_level', 'cefr', 'cefr_code']) {
      if (!row.containsKey(field)) continue;
      final next = _displayLevel(row[field]);
      if (next == 'UNKNOWN' || (level != null && next != level)) return 'UNKNOWN';
      level = next;
    }
    return level ?? 'UNKNOWN';
  }
  // Project canonical directed-pair records into the existing read-only view.
  // Explicit pair identity is mandatory; legacy SQLite rows remain unchanged.
  static Map<String, dynamic>? _projectCanonicalRow(Map<String, dynamic> row) {
    if (!row.containsKey('source_text') && !row.containsKey('target_text')) return row;
    final source = _safeText(row['source_text']);
    final target = _safeText(row['target_text']);
    bool absent(Object? v) => v == null || (v is List && !v.any((item) => _safeText(item) != null)) || (v is String && _safeText(v) == null);
    final flat = row['pair_id'] is String &&
        (row['source_language'] ?? row['source_language_code']) is String &&
        (row['target_language'] ?? row['target_language_code']) is String;
    if (source == null || target == null ||
        (row['pair_identity'] is! Map && !flat)) return null;
    if ((row['word'] != null && _safeText(row['word']) != source) ||
        (row['translation_ar'] != null && _safeText(row['translation_ar']) != target)) return null;
    final example = row['example_sentence'];
    final exampleLines = example is Map ? <String>[
      if (_safeText(example['source']) != null) _safeText(example['source'])!,
      if (_safeText(example['target']) != null) _safeText(example['target'])!,
    ] : <String>[];
    return <String, dynamic>{
      ...row, 'word': source, 'translation_ar': target,
      if (absent(row['examples']) && exampleLines.isNotEmpty) 'examples': exampleLines,
      if (absent(row['forms']) && _safeText(row['plural_form']) != null)
        'forms': <String>[_safeText(row['plural_form'])!],
    };
  }
  static String _foldSearch(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\u0640\u064B-\u065F\u0670]'), '')
      // Fold Arabic variants, bidi controls and numerals for lookup only.
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll('ی', 'ي').replaceAll('ک', 'ك')
      .replaceAll(RegExp(r'[\u00AD\u034F\u061C\u180E\u200B-\u200F\u202A-\u202E\u2060-\u206F\uFE00-\uFE0F\uFEFF]'), '')
      .replaceAllMapped(RegExp(r'[\u0660-\u0669\u06F0-\u06F9]'), (match) {
        final digit = match[0]!.codeUnitAt(0);
        return String.fromCharCode(
            48 + digit - (digit < 0x06F0 ? 0x0660 : 0x06F0));
      })
      .replaceAll('a\u0308', 'ae')
      .replaceAll('o\u0308', 'oe')
      .replaceAll('u\u0308', 'ue')
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss').replaceAll(RegExp(r'[\s\u00A0\u2007\u202F\u200B]+'), ' ').trim();
  static bool _listContainsSearch(Object? value, String query) {
    if (value is String) return _foldSearch(value).contains(query);
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
    final index = _cardIndex < rows.length ? _cardIndex : 0;
    final row = rows[index];
    final word = _safeText(row['word']) ?? '';
    final article = _safeText(row['article']);
    final translation = _safeText(row['translation_ar']);
    final level = _rowDisplayLevel(row);
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
                  Semantics(
                    key: const Key('study-card-announcement'),
                    liveRegion: true,
                    excludeSemantics: true,
                    label: 'بطاقة ${index + 1} من ${rows.length}: $displayWord',
                    child: Text(displayWord,
                      key: const Key('study-source'),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  const SizedBox(height: 20),
                  if (_quizMode) ...[
                    const Text(
                      'اختبار مراجعة ذاتية: قارن إجابتك بالمحتوى المحلي؛ '
                      'المطابقة نصية فقط، ولا تُحفظ نتيجة.',
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
                  if (_quizMode && _showAnswer && translation != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _foldSearch(_quizController.text) == _foldSearch(translation)
                            ? 'مطابقة نصية بعد توحيد الكتابة؛ ليست تصحيحًا للمعنى.'
                            : 'النص مختلف عن المرجع؛ قد تكون صحيحة بصياغة أخرى.',
                        key: const Key('study-quiz-text-match'),
                        textAlign: TextAlign.center,
                      ),
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
              // Practice must offer the same attested sense, forms and examples
              // as the vocabulary list, without inventing content or grading.
              TextButton.icon(
                key: const Key('study-word-details'),
                onPressed: () => _showWordDetails(row),
                icon: const Icon(Icons.info_outline),
                label: const Text('تفاصيل المفردة'),
              ),
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
    if (_detailsRoute?.isActive ?? false) return;
    const maxDetailItems = 32;
    List<String> lines(Object? value) => value is String
        ? <String>[value].map(_safeText).whereType<String>().toList(growable: false)
        : value is List
            ? value.take(maxDetailItems).whereType<String>()
                .map(_safeText).whereType<String>().toList(growable: false)
            : const <String>[];
    bool hasMoreItems(Object? value) =>
        value is List && value.length > maxDetailItems;
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
    final level = _rowDisplayLevel(row);
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
                detail('الصيغ والتصريفات', [
                  if (forms.isEmpty) 'لا تتوفر صيغ موثقة في هذا السجل.',
                  ...forms,
                  if (hasMoreItems(row['forms']))
                    'تُعرض أول 32 خانة فقط من الصيغ المتاحة في الحزمة.',
                ]),
                detail('أمثلة الاستخدام', [
                  if (examples.isEmpty) 'لا تتوفر أمثلة موثقة في هذا السجل.',
                  ...examples,
                  if (hasMoreItems(row['examples']))
                    'تُعرض أول 32 خانة فقط من الأمثلة المتاحة في الحزمة.',
                ]),
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
          _dismissStaleDetails();
        _searchController.clear();
      _searchQuery = '';
      _load(preservePrevious: false);
    }
  }
  @override
  void dispose() {
    _requestId++;
    _dismissStaleDetails();
    _searchController.dispose();
    _quizController.dispose();
    super.dispose();
  }
  String get _sourceLanguage => _normalizedLanguageCode(widget.languageCode);
  String get _targetLanguage => _normalizedLanguageCode(widget.targetLanguageCode);
  bool get _supportsDirectedPair =>
      _sourceLanguage == 'de' && _targetLanguage == 'ar' &&
      LocalTopicCatalog.supportsBundledTopics(_sourceLanguage);
  // Reject mismatched pair/level metadata from alternate readers; legacy
  // rows may omit it, and unknown CEFR is never inferred.
  bool _rowBelongsToSelection(Map<String, dynamic> row) {
    final word = row['word'];
    if (_safeText(word) == null) return false;
    bool matchesWhenDeclared(String field, String expected) {
      if (!row.containsKey(field)) return true;
      final value = row[field];
      return value is String &&
          value.trim().toLowerCase() == expected.toLowerCase();
    }
    if (!matchesWhenDeclared('section_id', widget.section.id) ||
        !matchesWhenDeclared('language_code', _sourceLanguage) ||
        !matchesWhenDeclared('source_language_code', _sourceLanguage) ||
        !matchesWhenDeclared('target_language_code', _targetLanguage) ||
        !matchesWhenDeclared(
            'translation_language_code', _targetLanguage)) {
      return false;
    }
    if (!matchesWhenDeclared('source_language', _sourceLanguage) ||
        !matchesWhenDeclared('source', _sourceLanguage) ||
        !matchesWhenDeclared('target_language', _targetLanguage) ||
        !matchesWhenDeclared('target', _targetLanguage) ||
        !matchesWhenDeclared('translation_language', _targetLanguage)) {
      return false;
    }
    if (row.containsKey('pair_id')) {
      final pairId = row['pair_id'];
      final expectedPair =
          '${_sourceLanguage.toLowerCase()}->${_targetLanguage.toLowerCase()}';
      if (pairId is! String ||
          pairId.trim().toLowerCase() != expectedPair) {
        return false;
      }
    }
    if (row.containsKey('pair_identity')) {
      final identity = row['pair_identity'];
      if (identity is! Map) return false;
      final pairId = identity['id'];
      final expectedPair =
          '${_sourceLanguage.toLowerCase()}->${_targetLanguage.toLowerCase()}';
      if (pairId is! String ||
          pairId.trim().toLowerCase() != expectedPair) {
        return false;
      }
      bool matchesPairField(String field, String expected) {
        if (!identity.containsKey(field)) return true;
        final value = identity[field];
        return value is String &&
            value.trim().toLowerCase() == expected.toLowerCase();
      }
      if (!matchesPairField('language_code', _sourceLanguage) ||
          !matchesPairField('source_language', _sourceLanguage) ||
          !matchesPairField('source_language_code', _sourceLanguage) ||
          !matchesPairField('source', _sourceLanguage) ||
          !matchesPairField('target_language', _targetLanguage) ||
          !matchesPairField('target_language_code', _targetLanguage) ||
          !matchesPairField('translation_language_code', _targetLanguage) ||
          !matchesPairField('translation_language', _targetLanguage) ||
          !matchesPairField('target', _targetLanguage) ||
          !matchesPairField('source_direction', 'ltr') ||
          !matchesPairField('target_direction', 'rtl')) {
        return false;
      }
    }
    // Respect every explicit CEFR alias; an unknown level stays UNKNOWN.
    for (final field in const <String>['cefr_level', 'cefr', 'cefr_code']) {
      final level = _displayLevel(row[field]);
      if (level != 'UNKNOWN' && level != widget.cefr.toUpperCase()) return false;
    }
    return true;
  }
  Future<void> _load({bool preservePrevious = true}) async {
    final previousRows = preservePrevious ? _rows : const <Map<String, dynamic>>[];
    final requestId = ++_requestId;
    if (!_supportsDirectedPair) {
      setState(() {
        _rows = const [];
        _loading = false;
        _failed = false;
        _staleSnapshot = false;
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
      _rows = previousRows;
      _studyMode = false;
      _quizMode = false;
      _cardIndex = 0;
      _resetCardAnswer();
    });
    try {
      final loader = widget.loadWords ?? LocalTopicCatalog.loadSection;
      final rows = await loader(
        sectionId: widget.section.id,
        cefr: widget.cefr,
        languageCode: _sourceLanguage,
      ).timeout(const Duration(seconds: 30));
      if (!mounted || requestId != _requestId) return;
      final accepted = rows.map(_projectCanonicalRow)
          .whereType<Map<String, dynamic>>().where(_rowBelongsToSelection)
          .take(50).toList(growable: false);
      // An empty refresh cannot silently erase a verified snapshot;
      // a nonempty unverified response must not masquerade as an empty pack.
      if (rows.isEmpty ? previousRows.isNotEmpty : accepted.isEmpty) {
        throw StateError('Topic reader returned no verified rows');
      }
      setState(() {
        _rows = accepted;
        _loading = false;
        _staleSnapshot = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _rows = previousRows;
        _loading = false;
        _failed = previousRows.isEmpty;
        _staleSnapshot = previousRows.isNotEmpty;
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
                key: const Key('topic-content-refresh'),
                tooltip: 'تحديث المفردات المحلية',
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
                      decoration: InputDecoration(
                        labelText: 'ابحث بالكلمة أو الترجمة',
                        labelStyle: const TextStyle(color: Colors.black54),
                        prefixIcon: const Icon(Icons.search, color: Colors.black54),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                key: const Key('topic-search-clear'),
                                tooltip: 'مسح البحث وإظهار المفردات',
                                icon: const Icon(Icons.clear, color: Colors.black54),
                                onPressed: () => setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _cardIndex = 0;
                                  _resetCardAnswer();
                                }),
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                )
              : null,
        ),
        bottomNavigationBar: _staleSnapshot && !_loading
            ? SafeArea(
                child: MaterialBanner(
                  key: const Key('topic-stale-warning'),
                  content: const Semantics(
                    key: Key('topic-stale-announcement'),
                    liveRegion: true,
                    child: Text('تعذر تحديث المفردات المحلية؛ تعرض آخر نسخة متوفرة. '
                        'قد لا تعكس الحزمة المثبتة حالياً.'),
                  ),
                  actions: [
                    TextButton(
                      key: const Key('topic-stale-retry'),
                      onPressed: _load,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            : null,
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
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      const Semantics(
                        liveRegion: true,
                        child: Text(
                          'جارٍ قراءة المفردات المحلية...',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        key: const Key('topic-loading-retry'),
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة الآن'),
                      ),
                    ],
                  ),
                ),
              )
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
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'لا توجد مفردات موثقة لهذا الموضوع والمستوى '
                                'في الحزمة المثبتة.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                key: const Key('topic-empty-refresh'),
                                onPressed: _load,
                                icon: const Icon(Icons.refresh),
                                label: const Text('تحديث المحتوى المحلي'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : matchingRows.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Semantics(
                                key: Key('topic-no-results-announcement'),
                                liveRegion: true,
                                child: Text('لا توجد نتائج مطابقة ضمن المفردات المحمّلة (حتى 50 كلمة). '
                                    'امسح البحث لعرض الكلمات المتوفرة.',
                                    textAlign: TextAlign.center),
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
                          final level = _rowDisplayLevel(row);
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