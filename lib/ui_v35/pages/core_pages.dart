import 'package:flutter/material.dart';

import '../../core/learning_core.dart';
import '../../models/content.dart';
import '../../models/learner.dart';
import '../../services/features.dart';
import '../../services/release.dart';
import '../../services/repository.dart';
import '../../services/search_index.dart';
import '../../language/language_text_normalizer.dart';
import '../../services/verb_index.dart';
import '../../services/word_profile_service.dart';
import '../../language/language_presentation.dart';
import '../../language/language_exercise_strategy.dart';
import '../../language/language_content_quality.dart';
import '../../features/audio/domain/services/i_audio_runtime.dart';
import '../placement/adaptive_placement_page.dart';
import '../../models/word_profile.dart';
import '../safe_ui.dart';

/// Independent, low-coupling pages extracted from the root UI composition file.
///
/// Public widget names and constructor contracts intentionally remain unchanged
/// so existing navigation code does not need behavioral changes.

class WeeklyPage extends StatelessWidget {
  final LearnerState state;
  const WeeklyPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final report = WeeklyReport.from(state);
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الأسبوع')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'آخر 7 أيام',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _box('المحاولات', '${report.attempts}'),
          _box(
            'الدقة',
            report.attempts == 0
                ? 'لا توجد بيانات'
                : '${(report.accuracy * 100).round()}%',
          ),
          _box('الكلمات المكتسبة', '${report.learned}'),
          _box('للمراجعة', '${report.reviews}'),
          const SizedBox(height: 10),
          Text(
            report.attempts == 0
                ? 'ابدأ جلسة حتى يصبح التقرير مبنيًا على بيانات حقيقية.'
                : report.accuracy >= .8
                    ? 'أداء جيد. الآن نركز على النقل والاحتفاظ.'
                    : 'نحتاج مزيدًا من المحاولات المتنوعة.',
          ),
        ],
      ),
    );
  }

  Widget _box(String label, String value) => Card(
        child: ListTile(
          title: Text(label),
          trailing: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      );
}

class GermanyRealityPage extends StatelessWidget {
  final LearnerRepository repo;
  final VoidCallback onDone;
  final LanguagePresentation presentation;

  const GermanyRealityPage({
    super.key,
    required this.repo,
    required this.onDone,
    required this.presentation,
  });

  @override
  Widget build(BuildContext context) {
    final realWorld = presentation.realWorld;
    return Scaffold(
      appBar: AppBar(title: Text(realWorld.title)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(realWorld.subtitle),
          const SizedBox(height: 8),
          ...realWorld.scenarios.map(
            (scenario) => Card(
              child: ListTile(
                title: Text(scenario.title),
                subtitle: Text(
                  '${scenario.targetText}\n${scenario.sourceText}',
                ),
                isThreeLine: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RealityPractice(
                      repo: repo,
                      title: scenario.title,
                      targetText: scenario.targetText,
                      sourceText: scenario.sourceText,
                      onDone: onDone,
                      presentation: presentation,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RealityPractice extends StatefulWidget {
  final LearnerRepository repo;
  final String title;
  final String targetText;
  final String sourceText;
  final VoidCallback onDone;
  final LanguagePresentation presentation;

  const RealityPractice({
    super.key,
    required this.repo,
    required this.title,
    required this.targetText,
    required this.sourceText,
    required this.onDone,
    required this.presentation,
  });

  @override
  State<RealityPractice> createState() => _RealityState();
}

class _RealityState extends State<RealityPractice> {
  String answer = '';
  bool done = false;
  bool correct = false;
  late DateTime start;

  @override
  void initState() {
    super.initState();
    start = DateTime.now();
  }

  Future<void> submit() async {
    String norm(String value) => value
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    correct = norm(answer) == norm(widget.targetText);
    await widget.repo.record(
      item: ContentItem(
        id: 'reality_${widget.title}',
        german: widget.targetText,
        arabic: widget.sourceText,
        sentence: widget.targetText,
        sentenceAr: widget.sourceText,
        topic: widget.title,
        skill: 'transfer',
        accepted: [widget.targetText],
      ),
      answer: answer,
      correct: correct,
      seconds: DateTime.now().difference(start).inSeconds.clamp(1, 999).toInt(),
      hinted: false,
      skillOverride: 'transfer',
    );
    if (!mounted) return;
    setState(() => done = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              widget.sourceText,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(widget.presentation.realWorld.targetLanguageInstruction),
            const SizedBox(height: 15),
            TextField(
              enabled: !done,
              onChanged: (value) => answer = value,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.presentation.realWorld.title,
              ),
            ),
            const SizedBox(height: 12),
            if (!done)
              FilledButton(onPressed: submit, child: const Text('تحقق'))
            else
              Card(
                child: ListTile(
                  title: Text(correct ? 'صحيح' : 'راجع الصياغة'),
                  subtitle: Text(widget.targetText),
                ),
              ),
            if (done)
              FilledButton(
                onPressed: () {
                  widget.onDone();
                  Navigator.pop(context);
                },
                child: const Text('إنهاء'),
              ),
          ],
        ),
      );
}

class PlacementPage extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final VoidCallback onDone;
  final LanguagePresentation presentation;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguageContentQuality contentQuality;
  final IAudioRuntime audioRuntime;
  final String languageCode;
  final String sourceLanguageCode;

  const PlacementPage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.onDone,
    required this.presentation,
    required this.exerciseStrategy,
    required this.contentQuality,
    required this.audioRuntime,
    required this.languageCode,
    required this.sourceLanguageCode,
  });

  @override
  Widget build(BuildContext context) => AdaptivePlacementPage(
        repo: repo,
        corpus: corpus,
        exerciseStrategy: exerciseStrategy,
        contentQuality: contentQuality,
        placementPresentation: presentation.placement,
        targetLanguageName: presentation.targetLanguageName,
        languageCode: languageCode,
        sourceLanguageCode: sourceLanguageCode,
        audioRuntime: audioRuntime,
        onDone: onDone,
      );
}

class QualityV35 extends StatelessWidget {
  const QualityV35({super.key});

  @override
  Widget build(BuildContext context) {
    final failed = releaseGates.where((gate) => !gate.passed).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Quality Center')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            '$failed بوابات غير مكتملة',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...releaseGates.map(
            (gate) => Card(
              child: ListTile(
                leading: Icon(
                  gate.passed ? Icons.check_circle : Icons.lock_outline,
                ),
                title: Text(gate.name),
                subtitle: Text(gate.note),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'لا نعلن عن ميزة كأنها مكتملة إذا كانت مجرد Prototype.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class FeatureStatusPage extends StatelessWidget {
  const FeatureStatusPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('حالة أدوات التطبيق')),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: featureRegistry
              .map(
                (feature) => Card(
                  child: ListTile(
                    leading: Icon(
                      feature.active
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                    ),
                    title: Text(feature.name),
                    subtitle: Text(feature.note),
                    trailing: Text(feature.active ? 'مفعّل' : 'قيد التطوير'),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      );
}

class CategoriesPage extends StatelessWidget {
  final LearnerRepository repo;
  final SearchIndex<ContentItem> searchIndex;
  final LanguagePresentation presentation;
  const CategoriesPage({
    super.key,
    required this.repo,
    required this.searchIndex,
    required this.presentation,
  });
  @override
  Widget build(BuildContext c) {
    final m = searchIndex.topicGroups;
    final ks = m.keys.toList()
      ..sort((a, b) => (m[b]?.length ?? 0).compareTo(m[a]?.length ?? 0));
    return Scaffold(
      appBar: AppBar(title: const Text('الأقسام والفئات')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: ks.length,
        itemBuilder: (c, i) {
          final k = ks[i], xs = m[k] ?? const <ContentItem>[];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(
                k,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${xs.length} كلمة'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                c,
                MaterialPageRoute(
                  builder: (_) => CategoryWordsPage(
                    title: k,
                    items: xs,
                    repo: repo,
                    presentation: presentation,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryWordsPage extends StatefulWidget {
  final String title;
  final List<ContentItem> items;
  final LearnerRepository repo;
  final LanguagePresentation presentation;
  const CategoryWordsPage({
    super.key,
    required this.title,
    required this.items,
    required this.repo,
    required this.presentation,
  });
  @override
  State<CategoryWordsPage> createState() => _CategoryWordsPageState();
}

class _CategoryWordsPageState extends State<CategoryWordsPage> {
  final SafeTtsController _tts = SafeTtsController();
  Future<void> _speak(String text) => _tts.speak(text);
  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: widget.items.length,
          itemBuilder: (c, i) {
            final x = widget.items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            x.sourceText,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                        IconButton(
                          tooltip: widget.presentation.pronunciationTooltip,
                          onPressed: () => _speak(x.sourceText),
                          icon: const Icon(Icons.volume_up_outlined),
                        ),
                      ],
                    ),
                    Text(x.translationText,
                        style: const TextStyle(fontSize: 16)),
                    const Divider(height: 20),
                    Text(
                      x.exampleText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 4),
                    Text(x.exampleTranslationText),
                    if (x.grammaticalMarker.isNotEmpty ||
                        x.pluralForm.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (x.grammaticalMarker.isNotEmpty)
                            Chip(
                              label: Text(
                                '${widget.presentation.grammaticalMarkerLabel}: ${x.grammaticalMarker}',
                              ),
                            ),
                          if (x.pluralForm.isNotEmpty)
                            Chip(
                              label: Text(
                                '${widget.presentation.pluralLabel}: ${x.pluralForm}',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
}

class SearchDictionaryPage extends StatefulWidget {
  final LearnerRepository repo;
  final SearchIndex<ContentItem> searchIndex;
  final VerbIndex verbIndex;
  final LanguagePresentation presentation;
  final LanguageTextNormalizer textNormalizer;
  const SearchDictionaryPage({
    super.key,
    required this.repo,
    required this.searchIndex,
    required this.verbIndex,
    required this.presentation,
    required this.textNormalizer,
  });
  @override
  State<SearchDictionaryPage> createState() => _SearchDictionaryState();
}

class _SearchDictionaryState extends State<SearchDictionaryPage> {
  String q = '';
  late final LearnerState state = widget.repo.load();
  final Map<String, WordProfile<ContentItem>> _profiles =
      <String, WordProfile<ContentItem>>{};
  late final Map<String, List<Attempt>> _attemptsByItem = _groupAttempts(
    state.attempts,
  );
  static Map<String, List<Attempt>> _groupAttempts(List<Attempt> attempts) {
    final grouped = <String, List<Attempt>>{};
    for (final attempt in attempts) {
      (grouped[attempt.itemId] ??= <Attempt>[]).add(attempt);
    }
    return grouped;
  }

  final SafeTtsController _tts = SafeTtsController();
  Future<void> _speak(String text) => _tts.speak(text);
  WordProfile<ContentItem> _profileFor(ContentItem item) =>
      _profiles[item.id] ??= WordProfileService.build(
        item,
        state,
        searchIndex: widget.searchIndex,
        verbIndex: widget.verbIndex,
        textNormalizer: widget.textNormalizer,
        itemAttempts: _attemptsByItem[item.id] ?? const <Attempt>[],
      );
  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final query = widget.textNormalizer.answer(q);
    final results = widget.searchIndex.search(query, limit: 60);
    return Scaffold(
      appBar: AppBar(title: const Text('البحث والقاموس')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => q = v),
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'البحث',
                hintText: 'ابحث بالألمانية أو العربية',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty && q.trim().isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 48),
                          const SizedBox(height: 10),
                          const Text(
                            'لا توجد نتيجة مطابقة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'جرّب الكلمة الألمانية، ترجمتها العربية، صيغة الجمع، أو جزءًا من الجملة.',
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: results.length,
                    itemBuilder: (c, i) {
                      final x = results[i];
                      return _DictionaryWordCard(
                        item: x,
                        profile: _profileFor(x),
                        speak: _speak,
                        presentation: widget.presentation,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DictionaryWordCard extends StatelessWidget {
  final ContentItem item;
  final WordProfile<ContentItem> profile;
  final Future<void> Function(String) speak;
  final LanguagePresentation presentation;
  const _DictionaryWordCard({
    required this.item,
    required this.profile,
    required this.speak,
    required this.presentation,
  });
  @override
  Widget build(BuildContext c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.displayForm,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                IconButton(
                  tooltip: presentation.pronunciationTooltip,
                  onPressed: () => speak(item.sourceText),
                  icon: const Icon(Icons.volume_up_outlined),
                ),
              ],
            ),
            Text(item.translationText, style: const TextStyle(fontSize: 16)),
            if (item.grammaticalMarker.isNotEmpty || item.pluralForm.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (item.grammaticalMarker.isNotEmpty)
                      Chip(
                        label: Text(
                          '${presentation.grammaticalMarkerLabel}: ${item.grammaticalMarker}',
                        ),
                      ),
                    if (item.pluralForm.isNotEmpty)
                      Chip(
                        label: Text(
                          '${presentation.pluralLabel}: ${item.pluralForm}',
                        ),
                      ),
                  ],
                ),
              ),
            const Divider(height: 18),
            Text(
              item.exampleText,
              style: const TextStyle(fontWeight: FontWeight.w700),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 4),
            Text(item.exampleTranslationText),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الإتقان: ${profile.masteryPercent}% • ${profile.masteryLabel}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  profile.masteryPercent >= 85
                      ? 'جاهزة للانتقال'
                      : 'جرعة إضافية',
                ),
              ],
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(value: profile.masteryScore),
            if (profile.relatedForms.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'تصريفات/أشكال: ${profile.relatedForms.join(' • ')}',
                  textDirection: TextDirection.ltr,
                ),
              ),
            if (profile.relatedWords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'كلمات مرتبطة: ${profile.relatedWords.join(' • ')}',
                  textDirection: TextDirection.ltr,
                ),
              ),
            if (profile.relatedExamples.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'أمثلة مرتبطة: ${profile.relatedExamples.take(3).join('  |  ')}',
                  textDirection: TextDirection.ltr,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  profile.due
                      ? Icons.schedule
                      : profile.needsPractice
                          ? Icons.school_outlined
                          : Icons.check_circle_outline,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    profile.due
                        ? 'مستحقة للمراجعة'
                        : profile.needsPractice
                            ? 'تحتاج تثبيتًا'
                            : 'مستقرة',
                  ),
                ),
                const SizedBox(width: 8),
                Text('${profile.attempts} محاولات'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
