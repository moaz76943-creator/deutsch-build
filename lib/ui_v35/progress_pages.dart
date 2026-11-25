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
    final items = path.items;
    final totalItems = items.length + 6;
    return Scaffold(
      appBar: AppBar(title: const Text('مسارك الشخصي')),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        cacheExtent: 300,
        addAutomaticKeepAlives: false,
        itemCount: totalItems,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text('تركيز اليوم: ${path.focusSkill}'),
                subtitle: Text(
                  'الخطة: ${path.reviewCount} مراجعة • ${path.repairCount} علاج • ${path.newCount} جديد',
                ),
              ),
            );
          } else if (index == 1) {
            return const SizedBox(height: 12);
          } else if (index < 2 + items.length) {
            final x = items[index - 2];
            return RepaintBoundary(
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index - 1}')),
                  title: Text(
                    x.item.sourceText,
                    textDirection: TextDirection.ltr,
                  ),
                  subtitle: Text('${x.item.translationText}\n${x.reason}'),
                  isThreeLine: true,
                  trailing: Text(x.mode),
                ),
              ),
            );
          } else if (index == 2 + items.length) {
            return const SizedBox(height: 12);
          } else if (index == 3 + items.length) {
            return FilledButton.icon(
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
            );
          } else if (index == 4 + items.length) {
            return const SizedBox(height: 8);
          } else {
            return OutlinedButton.icon(
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
            );
          }
        },
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
            Text(
              'الخطوة التالية',
              style: Theme.of(c)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              item == null
                  ? 'لا يوجد عنصر ضعيف حالياً. أكمل الجلسات لتحليل أدائك.'
                  : '${item.sourceText} — ${item.translationText}',
              textDirection: item == null ? null : TextDirection.ltr,
            ),
            if (item != null) ...[
              const SizedBox(height: 8),
              Text('المهارة: ${focusSkill}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                    builder: (_) => WordProfilePage(
                      item: item,
                      repo: repo,
                      searchIndex: searchIndex,
                      verbIndex: verbIndex,
                      contentQuality: contentQuality,
                      textNormalizer: textNormalizer,
                    ),
                  ),
                ),
                child: const Text('افتح الملف الشخصي للكلمة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MasteryDashboardPage extends StatelessWidget {
  final LearnerRepository repo;
  const MasteryDashboardPage({super.key, required this.repo});
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final scores = MasteryDashboard.skillScores(state);
    final overall = MasteryDashboard.overall(state);
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الإتقان')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text('الإتقان الكلي: ${(overall * 100).round()}%'),
              subtitle: const Text('متوسط المهارات الأساسية'),
            ),
          ),
          const SizedBox(height: 12),
          ...scores.entries.map(
            (e) => ListTile(
              title: Text(LearningDashboardPage._skillName(e.key)),
              subtitle: LinearProgressIndicator(value: e.value),
              trailing: Text('${(e.value * 100).round()}%'),
            ),
          ),
        ],
      ),
    );
  }
}

class MistakeAnalysisPage extends StatelessWidget {
  final LearnerRepository repo;
  const MistakeAnalysisPage({super.key, required this.repo});
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final analysis = MistakeAnalysis.build(state.attempts);
    return Scaffold(
      appBar: AppBar(title: const Text('تحليل الأخطاء')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text('أكثر الأخطاء: ${analysis.topPattern}'),
              subtitle: Text('تكرار: ${analysis.topCount}'),
            ),
          ),
          const SizedBox(height: 12),
          ...analysis.patterns.map(
            (p) => ListTile(
              title: Text(p.pattern),
              trailing: Text('${p.count}'),
            ),
          ),
        ],
      ),
    );
  }
}

class StreakMilestonesPage extends StatelessWidget {
  final LearnerRepository repo;
  const StreakMilestonesPage({super.key, required this.repo});
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final milestones = StreakMilestonesEngine.milestones(state);
    return Scaffold(
      appBar: AppBar(title: const Text('إنجازات الاستمرارية')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ...milestones.map(
            (m) => Card(
              child: ListTile(
                leading: Icon(
                  m.achieved ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: m.achieved ? Colors.green : null,
                ),
                title: Text(m.title),
                subtitle: Text(m.description),
                trailing: Text('${m.days} أيام'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
