import 'package:flutter/material.dart';

import '../core/content_contract.dart';
import '../core/learning_core.dart';
import '../language/language_exercise_strategy.dart';
import '../language/language_presentation.dart';
import '../language/language_content_quality.dart';
import '../language/language_text_normalizer.dart';
import '../core/safe_runtime.dart';
import '../models/content.dart';
import '../models/learner.dart';
import '../services/repository.dart';
import '../services/adaptive_teacher.dart';
import '../services/daily_plan.dart';
import '../services/progress_snapshot_service.dart';
import '../services/mastery_dashboard.dart';
import '../language/language_content_intelligence.dart';
import '../services/mistake_analysis.dart';
import '../services/search_index.dart';
import '../services/verb_index.dart';
import '../services/speech_service.dart';
import '../services/privacy_settings.dart';
import '../services/learning_engine.dart';
import '../services/reading_practice.dart';
import '../models/learning_path.dart';
import '../services/word_profile_service.dart';
import '../models/mistake.dart';
import '../services/mistake_engine.dart';
import '../services/repair_engine.dart';
import '../services/streak_milestones_engine.dart';
import 'safe_ui.dart';
import 'learning_pages.dart';
import 'milestone_badges_page.dart';

part 'progress_pages_detail.dart';

class PersonalPathCard extends StatefulWidget {
  final LearnerRepository repo;
  final VoidCallback onDone;
  final int revision;
  final List<ContentItem> corpus;
  final SearchIndex searchIndex;
  final VerbIndex verbIndex;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final LanguageContentIntelligence contentIntelligence;
  const PersonalPathCard({
    required this.repo,
    required this.onDone,
    required this.revision,
    required this.corpus,
    required this.searchIndex,
    required this.verbIndex,
    required this.exerciseStrategy,
    required this.presentation,
    required this.contentQuality,
    required this.textNormalizer,
    required this.contentIntelligence,
  });
  @override
  State<PersonalPathCard> createState() => _PersonalPathCardState();
}

class _PersonalPathCardState extends State<PersonalPathCard> {
  late LearnerState _state;
  late LearningPath _path;

  @override
  void initState() {
    super.initState();
    _rebuildPlan();
  }

  @override
  void didUpdateWidget(covariant PersonalPathCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) _rebuildPlan();
  }

  void _rebuildPlan() {
    _state = widget.repo.load();
    _path = LearningEngine.buildPlan(
      widget.corpus,
      _state,
      exerciseStrategy: widget.exerciseStrategy,
      contentQuality: widget.contentQuality,
      contentIntelligence: widget.contentIntelligence,
      dailyGoal: 8,
    );
  }

  @override
  Widget build(BuildContext c) {
    final first = _path.items.isEmpty ? null : _path.items.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المسار الشخصي اليومي',
                    style: Theme.of(c)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Text('${_path.items.length}'),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              first == null
                  ? 'لا توجد عناصر صالحة الآن.'
                  : 'ابدأ بـ ${first.item.sourceText} — ${first.reason}',
            ),
            const SizedBox(height: 8),
            Text(
              'مراجعة ${_path.reviewCount} • علاج ${_path.repairCount} • جديد ${_path.newCount} • التركيز: ${_path.focusSkill}',
              style: Theme.of(c).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                    builder: (_) => PersonalizedPathPage(
                      repo: widget.repo,
                      corpus: widget.corpus,
                      searchIndex: widget.searchIndex,
                      verbIndex: widget.verbIndex,
                      onDone: widget.onDone,
                      exerciseStrategy: widget.exerciseStrategy,
                      presentation: widget.presentation,
                      contentQuality: widget.contentQuality,
                      textNormalizer: widget.textNormalizer,
                      contentIntelligence: widget.contentIntelligence,
                    ),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('افتح المسار'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalizedPathPage extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final SearchIndex searchIndex;
  final VerbIndex verbIndex;
  final VoidCallback onDone;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final LanguageContentIntelligence contentIntelligence;
  const PersonalizedPathPage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.searchIndex,
    required this.verbIndex,
    required this.onDone,
    required this.exerciseStrategy,
    required this.presentation,
    required this.contentQuality,
    required this.textNormalizer,
    required this.contentIntelligence,
  });
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final path = LearningEngine.buildPlan(
      corpus,
      state,
      exerciseStrategy: exerciseStrategy,
      contentQuality: contentQuality,
      contentIntelligence: contentIntelligence,
      dailyGoal: 10,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('مسارك الشخصي')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text('تركيز اليوم: ${path.focusSkill}'),
              subtitle: Text(
                'الخطة: ${path.reviewCount} مراجعة • ${path.repairCount} علاج • ${path.newCount} جديد',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...path.items.asMap().entries.map((e) {
            final x = e.value;
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${e.key + 1}')),
                title: Text(
                  x.item.sourceText,
                  textDirection: TextDirection.ltr,
                ),
                subtitle: Text('${x.item.translationText}\n${x.reason}'),
                isThreeLine: true,
                trailing: Text(x.mode),
              ),
            );
          }),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => CoreSession(
                  repo: repo,
                  corpus: corpus,
                  onDone: onDone,
                  exerciseStrategy: exerciseStrategy,
                  presentation: presentation,
                  contentQuality: contentQuality,
                  textNormalizer: textNormalizer,
                  contentIntelligence: contentIntelligence,
                ),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('ابدأ جلسة التدريب'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => ReadingPracticePage(
                  repo: repo,
                  corpus: corpus,
                  searchIndex: searchIndex,
                  verbIndex: verbIndex,
                  contentQuality: contentQuality,
                ),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('تابع بقراءة تفاعلية'),
          ),
        ],
      ),
    );
  }
}

class ReadingPracticePage extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final SearchIndex searchIndex;
  final VerbIndex verbIndex;
  final LanguageContentQuality contentQuality;
  const ReadingPracticePage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.searchIndex,
    required this.verbIndex,
    required this.contentQuality,
  });
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final p = ProgressSnapshotService.build(
      state.attempts,
      state.assessmentHistory,
    );
    final passage = ReadingPractice.build(
      corpus,
      contentQuality: contentQuality,
      focusSkill: p.weakestSkill,
      targetWords: 6,
      maxSentences: 5,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('القراءة التفاعلية')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(passage.title),
              subtitle: const Text(
                'اقرأ، اضغط على الكلمات، ثم تدرب على الجمل التي ظهرت لك.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...passage.sentences.map(
            (x) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      x.exampleText,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(c)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(x.exampleTranslationText),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: x.exampleText
                          .split(RegExp(r'\s+'))
                          .map(
                            (word) => ActionChip(
                              label: Text(
                                word,
                                textDirection: TextDirection.ltr,
                              ),
                              onPressed: () => _showWord(c, word, x),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'كلمات التركيز: ${passage.targetWords.join(' • ')}',
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  void _showWord(BuildContext c, String raw, LearningContent source) {
    final word = raw.replaceAll(RegExp(r'[^A-Za-zÄÖÜäöüß-]'), '').toLowerCase();
    final matches = searchIndex.search(word, limit: 3);
    showModalBottomSheet(
      context: c,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  raw,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  matches.isEmpty
                      ? 'من الجملة: ${source.translationText}'
                      : matches
                          .map(
                            (x) =>
                                '${x.sourceText} — ${x.translationText}${x.grammaticalMarker.isEmpty ? '' : ' • ${x.grammaticalMarker}'}',
                          )
                          .join('\n'),
                ),
                const SizedBox(height: 8),
                const Text('استخدم هذه الكلمة في جملة جديدة لتثبيتها.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningDashboardPage extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final SearchIndex searchIndex;
  final VerbIndex verbIndex;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final LanguageContentIntelligence contentIntelligence;
  const LearningDashboardPage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.searchIndex,
    required this.verbIndex,
    required this.exerciseStrategy,
    required this.presentation,
    required this.contentQuality,
    required this.textNormalizer,
    required this.contentIntelligence,
  });
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final action = AdaptiveTeacher.next(state);
    final plan = DailyPlan.from(state);
    final scores = LearningCore.skillScores(state);
    return Scaffold(
      appBar: AppBar(title: const Text('المدرس الذكي')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.psychology_outlined),
              title: Text(
                action.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(action.reason),
              trailing: Text('${action.itemCount}'),
            ),
          ),
          const SizedBox(height: 12),
          _NextStepCard(
            repo: repo,
            corpus: corpus,
            focusSkill: action.skill,
            searchIndex: searchIndex,
            verbIndex: verbIndex,
            contentQuality: contentQuality,
            textNormalizer: textNormalizer,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خطة اليوم',
                    style: Theme.of(c)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'المجموع: ${plan.total} • مراجعة: ${plan.review} • علاج: ${plan.repair} • جديد: ${plan.newContent}',
                  ),
                  Text(
                    'استماع: ${plan.listening} • إنتاج: ${plan.production} • التركيز: ${plan.focusSkill}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...scores.entries.map(
            (e) => ListTile(
              title: Text(_skillName(e.key)),
              subtitle: LinearProgressIndicator(value: e.value),
              trailing: Text('${(e.value * 100).round()}%'),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => CoreSession(
                  repo: repo,
                  corpus: corpus,
                  onDone: () => Navigator.pop(c),
                  exerciseStrategy: exerciseStrategy,
                  presentation: presentation,
                  contentQuality: contentQuality,
                  textNormalizer: textNormalizer,
                  contentIntelligence: contentIntelligence,
                ),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('ابدأ الخطة الآن'),
          ),
        ],
      ),
    );
  }

  static String _skillName(String s) =>
      const {
        'recall': 'التعرّف',
        'listening': 'الاستماع',
        'production': 'الإنتاج',
        'transfer': 'النقل',
      }[s] ??
      s;
}

class _NextStepCard extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final String focusSkill;
  final SearchIndex searchIndex;
  final VerbIndex verbIndex;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  const _NextStepCard({
    required this.repo,
    required this.corpus,
    required this.focusSkill,
    required this.searchIndex,
    required this.verbIndex,
    required this.contentQuality,
    required this.textNormalizer,
  });
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final item = LearningCore.weakestItemForSkill(
      state,
      focusSkill,
      corpus,
      isLearnable: contentQuality.isLearnable,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'خطوتك التالية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'أضعف مهارة حاليًا: ${LearningDashboardPage._skillName(focusSkill)}',
            ),
            if (item != null) ...[
              const SizedBox(height: 10),
              Text(
                item.grammaticalMarker.isEmpty
                    ? item.sourceText
                    : '${item.grammaticalMarker} ${item.sourceText}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${item.translationText} • ${WordProfileService.build(item, state, searchIndex: searchIndex, verbIndex: verbIndex, textNormalizer: textNormalizer, corpus: corpus).masteryPercent}% إتقان',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MistakeDashboardPage extends StatelessWidget {
  final LearnerRepository repo;
  const MistakeDashboardPage({super.key, required this.repo});
  @override
  Widget build(BuildContext c) {
    final report = MistakeAnalysis.from(repo.load().attempts);
    return Scaffold(
      appBar: AppBar(title: const Text('تحليل الأخطاء')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'أكثر المهارات احتياجًا للعلاج',
            style: Theme.of(c)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (report.bySkill.isEmpty)
            const Card(
              child: ListTile(
                title: Text('لا توجد بيانات كافية بعد.'),
                subtitle: Text(
                  'ابدأ عدة تمارين حتى يستطيع التطبيق اكتشاف النمط.',
                ),
              ),
            ),
          ...report.bySkill.map(
            (b) => Card(
              child: ListTile(
                title: Text(b.skill),
                subtitle: Text('${b.errors} أخطاء من ${b.attempts} محاولات'),
                trailing: Text('${(b.errorRate * 100).round()}%'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'عناصر تتكرر فيها الأخطاء',
            style: Theme.of(c)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          ...report.weakItems.map(
            (id) => ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(id),
              subtitle: const Text('أعد تدريبه في جلسة علاجية.'),
            ),
          ),
        ],
      ),
    );
  }
}

class SpeechPracticePage extends StatefulWidget {
  final LearnerRepository repo;
  const SpeechPracticePage({super.key, required this.repo});
  @override
  State<SpeechPracticePage> createState() => _SpeechPracticeState();
}

class _SpeechPracticeState extends State<SpeechPracticePage> {
  final SpeechService speech = SpeechService();
  final SafeTtsController tts = SafeTtsController();
  String heard = '',
      status = 'اضغط على الميكروفون ثم انطق جملة قصيرة بالألمانية.';
  bool listening = false;
  bool speechBusy = false;
  final target = 'Ich lerne Deutsch.';
  Future<void> speakTarget() => tts.speak(target, rate: .43);
  Future<void> toggle() async {
    if (speechBusy) return;
    if (listening) {
      speechBusy = true;
      try {
        await speech.stop();
        if (!mounted) return;
        setState(() => listening = false);
      } finally {
        speechBusy = false;
      }
      return;
    }
    speechBusy = true;
    try {
      final ok = await speech.listen(
        onResult: (SpeechResult r) {
          if (!mounted) return;
          setState(() {
            heard = r.recognizedWords;
            status = r.finalResult ? 'تم التقاط العبارة.' : 'أستمع...';
          });
        },
      );
      if (mounted)
        setState(() {
          listening = ok;
          if (!ok)
            status =
                'تعذر تشغيل التعرف الصوتي. تحقق من إذن الميكروفون وإعداد اللغة الألمانية.';
        });
    } finally {
      speechBusy = false;
    }
  }

  @override
  void dispose() {
    speech.dispose();
    tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('مختبر النطق')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
                'Shadowing: اسمع، كرر، ثم قارن النص الذي التقطه الجهاز.'),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('الجملة المستهدفة'),
                subtitle: Text(target, textDirection: TextDirection.ltr),
                trailing: IconButton(
                  tooltip: 'استمع للجملة المستهدفة',
                  onPressed: speakTarget,
                  icon: const Icon(Icons.volume_up_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text(
                  heard.isEmpty ? 'لم يتم التعرف بعد' : heard,
                  textDirection: TextDirection.ltr,
                ),
                subtitle: Text(status),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: toggle,
              icon: Icon(listening ? Icons.stop : Icons.mic),
              label: Text(listening ? 'إيقاف' : 'ابدأ النطق'),
            ),
            const SizedBox(height: 10),
            const Text(
              'ملاحظة: التعرف الصوتي يعتمد على خدمة/محرك الجهاز وقد يحتاج اتصالًا بالإنترنت حسب إعدادات Android.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
}

class PrivacyCenterPage extends StatefulWidget {
  final PrivacySettingsStore privacySettings;
  const PrivacyCenterPage({super.key, required this.privacySettings});
  @override
  State<PrivacyCenterPage> createState() => _PrivacyCenterState();
}

class _PrivacyCenterState extends State<PrivacyCenterPage> {
  bool cloud = false, speech = false, loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    cloud = await widget.privacySettings.cloudAiEnabled();
    speech = await widget.privacySettings.speechEnabled();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('الخصوصية')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.offline_bolt_outlined),
                      title: Text('الأساس المحلي'),
                      subtitle: Text('المحتوى والتقدم وSRS لا تحتاج إلى خادم.'),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('ميزات AI السحابية'),
                    subtitle: const Text(
                      'تسمح بإرسال النص الذي تختاره فقط إلى خادم AI آمن عند ربطه. مغلقة افتراضيًا.',
                    ),
                    value: cloud,
                    onChanged: (v) async {
                      final saved = await widget.privacySettings.setCloudAi(v);
                      if (saved && mounted) setState(() => cloud = v);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('التعرف الصوتي'),
                    subtitle: const Text(
                      'يسمح باستخدام ميكروفون الجهاز لتدريب النطق.',
                    ),
                    value: speech,
                    onChanged: (v) async {
                      final saved = await widget.privacySettings.setSpeech(v);
                      if (saved && mounted) setState(() => speech = v);
                    },
                  ),
                  const Divider(height: 28),
                  const Text(
                    'لا توجد مفاتيح API سرية داخل التطبيق. أي تكامل سحابي يجب أن يمر عبر طبقة آمنة ويستخدم HTTPS فقط.',
                  ),
                ],
              ),
      );
}

class MasteryDashboardPage extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final LanguageContentIntelligence contentIntelligence;
  const MasteryDashboardPage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.contentIntelligence,
  });
  @override
  Widget build(BuildContext c) {
    final snapshot = MasteryDashboard.build(
      repo.load(),
      corpus: corpus,
      contentIntelligence: contentIntelligence,
    );
    final pct = (double v) => '${(v * 100).round()}%';
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الإتقان الذكية')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'جاهزية الإتقان',
                    style: Theme.of(c)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pct(snapshot.readiness)} • ${snapshot.readinessLabel}',
                    style: Theme.of(c)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: snapshot.readiness),
                  const SizedBox(height: 10),
                  Text('الخطوة المقترحة: ${snapshot.actionLabel}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metric(c, 'قابلية الاسترجاع', snapshot.retrievability),
              ),
              Expanded(
                child: _metric(c, 'خطر النسيان', snapshot.retentionRisk),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.track_changes),
                  title: const Text('الدليل الفعلي'),
                  subtitle: Text(
                    '${snapshot.measuredItems} عنصرًا مقاسًا • ${snapshot.masteredItems} متقنًا • قوة الدليل ${pct(snapshot.evidenceStrength)}',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('المراجعة: ${snapshot.dueItems} مستحقة'),
                  subtitle: Text(
                    '${snapshot.overdueItems} متأخرة • المراجعة التالية المتوقعة: ${snapshot.nextReviewDays} يوم',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: Text('أخطاء نشطة: ${snapshot.activeErrorItems}'),
                  subtitle: Text('أضعف مهارة: ${snapshot.weakestSkill}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تغطية المحتوى',
                    style: Theme.of(c)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A1: ${snapshot.contentReport.a1Count} • A2: ${snapshot.contentReport.a2Count} • B1: ${snapshot.contentReport.b1Count}',
                  ),
                  Text(
                    'Word families: ${snapshot.contentReport.wordFamilyCount} • Near duplicates: ${snapshot.contentReport.nearDuplicatePairCount}',
                  ),
                ],
              ),
            ),
          ),
          if (snapshot.priorityItemIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'أولوية المراجعة',
              style: Theme.of(c)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            ...snapshot.priorityItemIds.map(
              (id) => ListTile(
                leading: const Icon(Icons.priority_high),
                title: Text(id),
                subtitle: const Text('اختاره SRS كعنصر ذي أولوية أعلى.'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(BuildContext c, String title, double value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: value),
              const SizedBox(height: 5),
              Text('${(value * 100).round()}%'),
            ],
          ),
        ),
      );
}
