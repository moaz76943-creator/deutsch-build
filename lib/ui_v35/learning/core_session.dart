part of '../learning_pages.dart';

class CoreSession extends StatefulWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final VoidCallback onDone;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final LanguageContentIntelligence contentIntelligence;
  const CoreSession({
    super.key,
    required this.repo,
    required this.corpus,
    required this.onDone,
    required this.exerciseStrategy,
    required this.presentation,
    required this.contentQuality,
    required this.textNormalizer,
    required this.contentIntelligence,
  });
  @override
  State<CoreSession> createState() => _CoreState();
}

class _CoreState extends State<CoreSession> {
  final SafeTtsController tts = SafeTtsController();
  late final UniversalSessionOrchestrator session;
  late LearnerState sessionState;
  late List<LearningContent> items;
  late List<LearningPathItem> plannedItems;
  int pos = 0;
  String answer = '';
  bool submitted = false, correct = false;
  late DateTime started;
  String mode = 'production';
  @override
  void initState() {
    super.initState();
    session = UniversalSessionOrchestrator(repository: widget.repo);
    sessionState = widget.repo.load();
    final corpus = widget.corpus;
    final plan = LearningEngine.buildPlan(
      corpus,
      sessionState,
      exerciseStrategy: widget.exerciseStrategy,
      contentQuality: widget.contentQuality,
      contentIntelligence: widget.contentIntelligence,
      dailyGoal: 6,
    );
    plannedItems = plan.items;
    items = plannedItems.map((x) => x.item).toList();
    if (items.isEmpty) items = corpus.take(6).toList();
    started = DateTime.now();
    mode = plannedItems.isEmpty
        ? _fallbackMode(0, sessionState)
        : _modeForPlanItem(plannedItems[0]);
  }

  LearningContent get item => items[pos];
  String _modeForPlanItem(LearningPathItem planned) {
    const valid = {'recall', 'listening', 'production', 'transfer'};
    if (valid.contains(planned.mode)) return planned.mode;
    if (valid.contains(planned.item.skill)) return planned.item.skill;
    if (planned.mode == 'repair' || planned.mode == 'review') return 'recall';
    if (planned.mode == 'consolidate') return 'production';
    return _fallbackMode(pos, sessionState);
  }

  String _fallbackMode(int index, LearnerState s) {
    const modes = ['recall', 'listening', 'production', 'transfer'];
    final weak = LearningCore.weakestSkill(s);
    if (index == 0) return weak;
    return modes[index % modes.length];
  }

  String get prompt {
    final d = depthFor(item);
    switch (mode) {
      case 'recall':
        return 'ما الكلمة بـ${widget.presentation.targetLanguageName}؟ ${item.translationText}';
      case 'listening':
        return 'استمع ثم اكتب الجملة التي تسمعها.';
      case 'transfer':
        return d.transferPrompt.isNotEmpty
            ? d.transferPrompt
            : item.exampleTranslationText;
      default:
        return d.transferPrompt.isNotEmpty
            ? d.transferPrompt
            : item.exampleTranslationText;
    }
  }

  String get expected {
    final d = depthFor(item);
    switch (mode) {
      case 'recall':
        return item.sourceText;
      case 'listening':
        return item.exampleText;
      case 'transfer':
        return d.transferAnswer.isNotEmpty
            ? d.transferAnswer
            : item.exampleText;
      default:
        return d.transferAnswer.isNotEmpty
            ? d.transferAnswer
            : (item.acceptedForms.isNotEmpty
                ? item.acceptedForms.first
                : item.sourceText);
    }
  }

  Future<void> submit() async {
    if (submitted) return;
    final a = widget.textNormalizer.answer(answer);
    final e = widget.textNormalizer.answer(expected);
    correct = a == e ||
        item.acceptedForms.any(
          (value) => widget.textNormalizer.answer(value) == a,
        );
    await session.record(
      SessionReviewInput(
        item: item,
        answer: answer,
        correct: correct,
        seconds:
            DateTime.now().difference(started).inSeconds.clamp(1, 999).toInt(),
        hinted: false,
        facetType: switch (mode) {
          'listening' => ReviewFacetType.listening,
          'production' => ReviewFacetType.production,
          _ => ReviewFacetType.meaningRecall,
        },
        variantKey: switch (mode) {
          'listening' => 'session',
          'production' => 'session',
          _ => null,
        },
        skillOverride: mode,
      ),
    );
    if (!mounted) return;
    setState(() => submitted = true);
  }

  Future<void> speak() => tts.speak(item.exampleText, rate: .42);
  @override
  void dispose() {
    session.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text('جلسة ${pos + 1}/${items.length}')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Chip(
              label: Text(
                mode == 'listening'
                    ? 'Listening'
                    : mode == 'transfer'
                        ? 'Transfer'
                        : mode == 'recall'
                            ? 'Recognition'
                            : 'Production',
              ),
            ),
            const SizedBox(height: 12),
            Text(item.topic, style: Theme.of(c).textTheme.labelLarge),
            const SizedBox(height: 7),
            Text(
              prompt,
              style: Theme.of(c)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (mode == 'listening')
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: FilledButton.icon(
                  onPressed: speak,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('استمع'),
                ),
              ),
            const SizedBox(height: 14),
            TextField(
              enabled: !submitted,
              onChanged: (x) => answer = x,
              textDirection: TextDirection.ltr,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'إجابتك بـ${widget.presentation.targetLanguageName}',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!submitted)
              FilledButton(onPressed: submit, child: const Text('تحقق'))
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        correct ? '✓ إجابة صحيحة' : '✗ نحتاج تدريبًا إضافيًا',
                        style: Theme.of(c)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text('الإجابة المستهدفة: $expected'),
                      if (depthFor(item).grammar.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('قاعدة: ${depthFor(item).grammar}'),
                        ),
                      if (depthFor(item).collocation.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child:
                              Text('تركيب مهم: ${depthFor(item).collocation}'),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (submitted)
              FilledButton(
                onPressed: () {
                  if (pos + 1 >= items.length) {
                    widget.onDone();
                    Navigator.pop(c);
                  } else {
                    setState(() {
                      pos++;
                      submitted = false;
                      answer = '';
                      started = DateTime.now();
                      mode = plannedItems.isEmpty
                          ? _fallbackMode(pos, sessionState)
                          : _modeForPlanItem(plannedItems[pos]);
                    });
                  }
                },
                child:
                    Text(pos + 1 >= items.length ? 'إنهاء الجلسة' : 'التالي'),
              ),
          ],
        ),
      );
}
