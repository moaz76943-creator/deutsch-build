part of '../learning_pages.dart';

class SmartAssessmentPage extends StatefulWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final LanguageContentIntelligence contentIntelligence;
  const SmartAssessmentPage({
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
  State<SmartAssessmentPage> createState() => _SmartAssessmentState();
}

class _SmartAssessmentState extends State<SmartAssessmentPage> {
  final SafeTtsController tts = SafeTtsController();
  late LearnerState assessmentState;
  late List<AssessmentQuestion> questions;
  final answers = <String, String>{};
  final responses = <AssessmentResponse>[];
  int index = 0;
  bool submitted = false;
  bool correct = false;
  bool saving = false;
  late DateTime started;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    assessmentState = widget.repo.load();
    final corpus = widget.corpus;
    questions = AssessmentEngine.build(
      corpus,
      assessmentState,
      exerciseStrategy: widget.exerciseStrategy,
      isLearnable: widget.contentQuality.isLearnable,
      questionCount: 8,
      seed: DateTime.now().day + DateTime.now().month,
    );
    if (questions.isEmpty) questions = const [];
    started = DateTime.now();
  }

  AssessmentQuestion get q => questions[index];
  String get _expected => q.expected;
  bool _matches(String value) {
    final a = assessmentNormalize(value);
    if (a.isEmpty) return false;
    return assessmentAnswerMatches(
      AssessmentResponse(
        questionId: q.id,
        itemId: q.itemId,
        answer: value,
        correct: true,
        hinted: false,
      ),
      q,
    );
  }

  Future<void> _speak() => tts.speak(q.expected, rate: .42);

  Future<void> _submit() async {
    if (submitted) return;
    final answer = answers[q.id] ?? '';
    correct = _matches(answer);
    responses.add(
      AssessmentResponse(
        questionId: q.id,
        itemId: q.itemId,
        answer: answer,
        correct: correct,
        hinted: false,
      ),
    );
    setState(() => submitted = true);
  }

  Future<void> _next() async {
    if (saving) return;
    if (saving || !mounted) return;
    if (index + 1 >= questions.length) {
      setState(() => saving = true);
      try {
        final corpus = widget.corpus;
        final result = AssessmentEngine.score(
          responses,
          corpus,
          exerciseStrategy: widget.exerciseStrategy,
        );
        for (final response in responses) {
          final item = assessmentFindItem(corpus, response.itemId);
          if (item == null) continue;
          final question = AssessmentEngine.questionFor(
            item,
            response.questionId,
            widget.exerciseStrategy,
          );
          await widget.repo.record(
            item: item,
            answer: response.answer,
            correct: response.correct,
            seconds: DateTime.now()
                .difference(started)
                .inSeconds
                .clamp(1, 999)
                .toInt(),
            hinted: response.hinted,
            skillOverride: question.skill,
          );
        }
        await widget.repo.recordAssessment(result);
        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AssessmentResultPage(
              result: result,
              history: assessmentState.assessmentHistory,
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => saving = false);
      }
      return;
    }
    setState(() {
      index++;
      submitted = false;
      correct = false;
      started = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext c) {
    if (questions.isEmpty)
      return Scaffold(
        appBar: AppBar(title: const Text('الاختبار الذكي')),
        body: const Center(child: Text('لا توجد أسئلة صالحة للاختبار حاليًا.')),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text('الاختبار الذكي ${index + 1}/${questions.length}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          LinearProgressIndicator(value: (index + 1) / questions.length),
          const SizedBox(height: 18),
          Chip(label: Text(_typeLabel(q.type))),
          const SizedBox(height: 12),
          Text(
            q.prompt,
            style: Theme.of(c)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (q.type == AssessmentQuestionType.listening)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.icon(
                onPressed: _speak,
                icon: const Icon(Icons.volume_up),
                label: const Text('استمع'),
              ),
            ),
          const SizedBox(height: 14),
          TextField(
            enabled: !submitted,
            onChanged: (v) => answers[q.id] = v,
            textDirection: TextDirection.ltr,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'إجابتك بـ${widget.presentation.targetLanguageName}',
            ),
          ),
          const SizedBox(height: 12),
          if (!submitted)
            FilledButton(onPressed: _submit, child: const Text('تحقق'))
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correct ? '✓ إجابة صحيحة' : '✗ تحتاج مراجعة',
                      style: Theme.of(c)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text('الإجابة المستهدفة: $_expected'),
                  ],
                ),
              ),
            ),
          if (submitted)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton(
                onPressed: _next,
                child: Text(
                  index + 1 >= questions.length ? 'عرض النتيجة' : 'التالي',
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tts.dispose();
    super.dispose();
  }

  static String _typeLabel(AssessmentQuestionType t) =>
      const {
        AssessmentQuestionType.recall: 'التعرّف',
        AssessmentQuestionType.grammar: 'القواعد',
        AssessmentQuestionType.translation: 'الترجمة',
        AssessmentQuestionType.listening: 'الاستماع',
        AssessmentQuestionType.production: 'الإنتاج',
      }[t] ??
      'غير معروف';
}

class AssessmentResultPage extends StatelessWidget {
  final AssessmentResult result;
  final List<AssessmentHistory> history;
  const AssessmentResultPage({
    super.key,
    required this.result,
    required this.history,
  });
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('نتيجة الاختبار')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${result.score.round()}%',
                      style: Theme.of(c)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${result.correct}/${result.answered} إجابات صحيحة • ${result.cleanCorrect} دون تلميح',
                    ),
                    const SizedBox(height: 8),
                    Text(_message(result.score)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'خريطة المهارات',
              style: Theme.of(c)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            ...result.skillScores.entries.map(
              (e) => ListTile(
                title: Text(e.key),
                subtitle: LinearProgressIndicator(value: e.value),
                trailing: Text('${(e.value * 100).round()}%'),
              ),
            ),
            const SizedBox(height: 8),
            if (result.weakSkills.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: const Text('ما الذي نركز عليه؟'),
                  subtitle: Text(result.weakSkills.join(' • ')),
                ),
              ),
            if (result.nextReviewItemIds.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.replay_outlined),
                  title: const Text('بطاقات تستحق المراجعة'),
                  subtitle: Text(
                    '${result.nextReviewItemIds.length} عناصر ستعود إلى خطة المراجعة.',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'آخر الاختبارات',
              style: Theme.of(c)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            ...history.take(5).map(
                  (h) => ListTile(
                    title: Text('${h.score.round()}%'),
                    subtitle: Text(
                      '${h.at.toLocal()} • ${h.weakSkills.isEmpty ? 'لا توجد نقاط ضعف محددة' : h.weakSkills.join('، ')}',
                    ),
                  ),
                ),
          ],
        ),
      );
  static String _message(double score) => score >= 85
      ? 'ممتاز. سنرفع التحدي ونركز على الاحتفاظ.'
      : score >= 70
          ? 'جيد. هناك مهارات تحتاج تثبيتًا إضافيًا.'
          : 'النتيجة تكشف نقاطًا تحتاج علاجًا؛ سنحوّلها إلى مراجعات مستهدفة.';
}

class PlanSummaryCard extends StatelessWidget {
  const PlanSummaryCard({super.key});
  @override
  Widget build(BuildContext c) => FutureBuilder<bool>(
        future: SubscriptionService.isPremium(),
        builder: (c, snap) {
          final premium = snap.data == true;
          return Card(
            child: ListTile(
              leading: Icon(
                premium ? Icons.workspace_premium : Icons.lock_open_outlined,
              ),
              title: Text(premium ? 'Premium مفعّل' : 'الخطة المجانية'),
              subtitle: Text(
                premium
                    ? 'كل مزايا التعلم المتقدمة متاحة لك.'
                    : 'جرّب الأساسيات مجانًا، واطّلع على الباقات المدفوعة للمزايا المتقدمة.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => SubscriptionPage(repo: null)),
              ),
            ),
          );
        },
      );
}
