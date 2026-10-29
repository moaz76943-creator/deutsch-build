part of 'progress_pages.dart';

class ProgressPage extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final LanguageContentIntelligence contentIntelligence;
  const ProgressPage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.exerciseStrategy,
    required this.presentation,
    required this.contentQuality,
    required this.textNormalizer,
    required this.contentIntelligence,
  });
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final p = ProgressSnapshotService.build(
      state.attempts,
      state.assessmentHistory,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('تطوري ومستواي')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    p.levelLabel,
                    style: Theme.of(c)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text('المؤشر الحالي ${(p.overall * 100).round()}%'),
                  const SizedBox(height: 6),
                  Text('أضعف مهارة: ${_skillName(p.weakestSkill)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...p.skillScores.entries.map(
            (e) => ListTile(
              title: Text(_skillName(e.key)),
              subtitle: LinearProgressIndicator(value: e.value),
              trailing: Text('${(e.value * 100).round()}%'),
            ),
          ),
          const SizedBox(height: 8),
          Text('عدد الاختبارات المحفوظة: ${p.assessedCount}'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => MilestoneBadgesPage(
                  currentStreak: state.streak,
                  engine: StreakMilestonesEngine.getInstance(),
                ),
              ),
            ),
            icon: const Icon(Icons.stars_outlined),
            label: const Text('إنجازات الاستمرارية'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => SmartAssessmentPage(
                  repo: repo,
                  corpus: corpus,
                  exerciseStrategy: exerciseStrategy,
                  presentation: presentation,
                  contentQuality: contentQuality,
                  textNormalizer: textNormalizer,
                  contentIntelligence: contentIntelligence,
                ),
              ),
            ),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('اختبار جديد'),
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
        'grammar': 'القواعد',
        'vocabulary': 'المفردات',
      }[s] ??
      s;
}

class MistakeCoachPage extends StatelessWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguageContentQuality contentQuality;
  const MistakeCoachPage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.exerciseStrategy,
    required this.contentQuality,
  });
  @override
  Widget build(BuildContext c) {
    final state = repo.load();
    final report = MistakeEngine.from(state.attempts, corpus);
    return Scaffold(
      appBar: AppBar(title: const Text('مدرب الأخطاء الذكي')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_fix_high_outlined),
              title: const Text('من الأخطاء إلى تدريب علاجي'),
              subtitle: Text(report.headline),
            ),
          ),
          const SizedBox(height: 10),
          if (report.items.isEmpty)
            const Card(
              child: ListTile(
                title: Text('لا توجد أخطاء متكررة بعد.'),
                subtitle: Text(
                  'أكمل اختبارات أو محادثات أو فحص كتابة ليبني التطبيق نمطًا عن أخطائك.',
                ),
              ),
            ),
          ...report.items.take(8).map(
                (m) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${m.errorCount}')),
                    title: Text(
                      '${m.itemId} • ${mistakeCategoryLabel(m.category)}',
                    ),
                    subtitle: Text(
                      '${m.errorCount} أخطاء من ${m.attemptCount} محاولات • شدة ${m.severity}%\n${m.correctiveStreak} إجابات صحيحة متتالية',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => MistakeRepairPage(
                          repo: repo,
                          mistake: m,
                          corpus: corpus,
                          exerciseStrategy: exerciseStrategy,
                          contentQuality: contentQuality,
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

class MistakeRepairPage extends StatefulWidget {
  final LearnerRepository repo;
  final MistakeRecord mistake;
  final List<ContentItem> corpus;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguageContentQuality contentQuality;
  const MistakeRepairPage({
    super.key,
    required this.repo,
    required this.mistake,
    required this.corpus,
    required this.exerciseStrategy,
    required this.contentQuality,
  });
  @override
  State<MistakeRepairPage> createState() => _MistakeRepairState();
}

class _MistakeRepairState extends State<MistakeRepairPage> {
  late final RepairDrill? drill;
  int step = 0;
  String answer = '';
  bool checked = false, correct = false;
  late DateTime started;
  @override
  void initState() {
    super.initState();
    drill = RepairEngine.build(
      widget.mistake,
      widget.corpus,
      exerciseStrategy: widget.exerciseStrategy,
      isLearnable: widget.contentQuality.isLearnable,
    );
    started = DateTime.now();
  }

  Future<void> submit() async {
    if (drill == null || checked || safeIndex(step, drill!.steps.length) < 0)
      return;
    final s = drill!.steps[safeIndex(step, drill!.steps.length)];
    String norm(String x) => x
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    correct = repairStepAccepts(s, answer, norm);
    setState(() => checked = true);
    if (widget.mistake.itemId.startsWith('writing:')) {
      if (!correct)
        await widget.repo.recordWritingMistake(
          issue: widget.mistake.normalizedKey,
          at: DateTime.now(),
        );
    } else {
      ContentItem? item;
      for (final x in widget.corpus) {
        if (x.id == widget.mistake.itemId) {
          item = x;
          break;
        }
      }
      if (item != null)
        await widget.repo.record(
          item: item,
          answer: answer,
          correct: correct,
          seconds: DateTime.now()
              .difference(started)
              .inSeconds
              .clamp(1, 999)
              .toInt(),
          hinted: false,
          skillOverride: item.skill,
        );
    }
    if (!mounted) return;
  }

  void next() {
    if (drill == null || safeIndex(step, drill!.steps.length) < 0) return;
    if (!correct) {
      setState(() {
        answer = '';
        checked = false;
        started = DateTime.now();
      });
      return;
    }
    if (step + 1 >= drill!.steps.length) {
      Navigator.pop(context);
    } else {
      setState(() {
        step++;
        answer = '';
        checked = false;
        started = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    if (drill == null || drill!.steps.isEmpty)
      return const Scaffold(
        body: Center(child: Text('لا يوجد تدريب آمن لهذا الخطأ.')),
      );
    final safeStep = safeIndex(step, drill!.steps.length);
    if (safeStep < 0)
      return const Scaffold(
        body: Center(child: Text('انتهى هذا التدريب بأمان.')),
      );
    final s = drill!.steps[safeStep];
    return Scaffold(
      appBar: AppBar(title: const Text('علاج الخطأ')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          LinearProgressIndicator(value: (step + 1) / 3),
          const SizedBox(height: 18),
          Text(
            'الخطوة ${step + 1} من 3',
            style: Theme.of(c).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            mistakeCategoryLabel(widget.mistake.category),
            style: Theme.of(c)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.prompt, style: Theme.of(c).textTheme.titleLarge),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            enabled: !checked,
            onChanged: (v) => answer = v,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'إجابتك بالألمانية',
            ),
          ),
          const SizedBox(height: 12),
          if (!checked)
            FilledButton(onPressed: submit, child: const Text('تحقق'))
          else
            Card(
              child: ListTile(
                leading: Icon(correct ? Icons.check_circle : Icons.refresh),
                title: Text(
                  correct
                      ? 'إجابة صحيحة — نرفع الإتقان تدريجيًا'
                      : 'ما زالت تحتاج تدريبًا',
                ),
                subtitle: Text(s.expected),
              ),
            ),
          if (checked)
            FilledButton(
              onPressed: next,
              child: Text(
                correct
                    ? (step + 1 >= 3 ? 'إنهاء' : 'الخطوة التالية')
                    : 'أعد المحاولة',
              ),
            ),
        ],
      ),
    );
  }
}
