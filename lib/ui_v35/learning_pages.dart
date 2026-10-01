import '../services/app_dependencies.dart';
import 'package:flutter/material.dart';
import '../core/learning_core.dart';
import '../core/content_contract.dart';
import '../language/language_exercise_strategy.dart';
import '../language/language_presentation.dart';
import '../language/language_content_quality.dart';
import '../models/content.dart';
import '../models/learner.dart';
import '../models/assessment.dart';
import '../services/repository.dart';
import '../services/subscription.dart';
import '../language/language_text_normalizer.dart';
import '../language/language_content_intelligence.dart';
import '../services/assessment_engine.dart';
import '../services/learning_engine.dart';
import '../models/learning_path.dart';
import 'account_pages.dart';
import 'safe_ui.dart';
import '../services/content_depth.dart';

class CoreSession extends StatefulWidget {
  final LearnerRepository repo; final List<ContentItem> corpus; final VoidCallback onDone; final LanguageExerciseStrategy exerciseStrategy; final LanguagePresentation presentation; final LanguageContentQuality contentQuality; final LanguageTextNormalizer textNormalizer; final LanguageContentIntelligence contentIntelligence;
  const CoreSession({super.key, required this.repo, required this.corpus, required this.onDone, required this.exerciseStrategy, required this.presentation, required this.contentQuality, required this.textNormalizer, required this.contentIntelligence});
  @override State<CoreSession> createState() => _CoreState();
}
class _CoreState extends State<CoreSession> {
  final SafeTtsController tts = SafeTtsController(); late LearnerState sessionState; late List<LearningContent> items; late List<LearningPathItem> plannedItems; int pos = 0; String answer = ''; bool submitted = false, correct = false; late DateTime started; String mode = 'production';
  @override void initState() {
    super.initState();
    sessionState = widget.repo.load();
    final corpus = widget.corpus;
    final plan = LearningEngine.buildPlan(corpus, sessionState, exerciseStrategy: widget.exerciseStrategy, contentQuality: widget.contentQuality, contentIntelligence: widget.contentIntelligence, dailyGoal: 6);
    plannedItems = plan.items;
    items = plannedItems.map((x) => x.item).toList();
    if (items.isEmpty) items = corpus.take(6).toList();
    started = DateTime.now();
    mode = plannedItems.isEmpty ? _fallbackMode(0, sessionState) : _modeForPlanItem(plannedItems[0]);
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
    const modes=['recall','listening','production','transfer'];
    final weak=LearningCore.weakestSkill(s);
    if (index == 0) return weak;
    return modes[index % modes.length];
  }
  String get prompt { final d = depthFor(item); switch (mode) { case 'recall': return 'ما الكلمة بـ${widget.presentation.targetLanguageName}؟ ${item.translationText}'; case 'listening': return 'استمع ثم اكتب الجملة التي تسمعها.'; case 'transfer': return d.transferPrompt.isNotEmpty ? d.transferPrompt : item.exampleTranslationText; default: return d.transferPrompt.isNotEmpty ? d.transferPrompt : item.exampleTranslationText; } }
  String get expected { final d = depthFor(item); switch (mode) { case 'recall': return item.sourceText; case 'listening': return item.exampleText; case 'transfer': return d.transferAnswer.isNotEmpty ? d.transferAnswer : item.exampleText; default: return d.transferAnswer.isNotEmpty ? d.transferAnswer : (item.acceptedForms.isNotEmpty ? item.acceptedForms.first : item.sourceText); } }
  Future<void> submit() async { if (submitted) return; final a = widget.textNormalizer.answer(answer); final e = widget.textNormalizer.answer(expected); correct = a == e || item.acceptedForms.any((value) => widget.textNormalizer.answer(value) == a); await widget.repo.record(item: item, answer: answer, correct: correct, seconds: DateTime.now().difference(started).inSeconds.clamp(1, 999).toInt(), hinted: false, skillOverride: mode); if (!mounted) return; setState(() => submitted = true); }
  Future<void> speak() => tts.speak( item.exampleText, rate: .42);
  @override void dispose() { tts.stop(); super.dispose(); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text('جلسة ${pos + 1}/${items.length}')), body: ListView(padding: const EdgeInsets.all(18), children: [
    Chip(label: Text(mode == 'listening' ? 'Listening' : mode == 'transfer' ? 'Transfer' : mode == 'recall' ? 'Recognition' : 'Production')),
    const SizedBox(height: 12), Text(item.topic, style: Theme.of(c).textTheme.labelLarge), const SizedBox(height: 7), Text(prompt, style: Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
    if (mode == 'listening') Padding(padding: const EdgeInsets.only(top: 14), child: FilledButton.icon(onPressed: speak, icon: const Icon(Icons.volume_up), label: const Text('استمع'))),
    const SizedBox(height: 14), TextField(enabled: !submitted, onChanged: (x) => answer = x, textDirection: TextDirection.ltr, minLines: 1, maxLines: 3, decoration: InputDecoration(labelText: 'إجابتك بـ${widget.presentation.targetLanguageName}', border: const OutlineInputBorder())), const SizedBox(height: 12),
    if (!submitted) FilledButton(onPressed: submit, child: const Text('تحقق')) else Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(correct ? '✓ إجابة صحيحة' : '✗ نحتاج تدريبًا إضافيًا', style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text('الإجابة المستهدفة: $expected'), if (depthFor(item).grammar.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('قاعدة: ${depthFor(item).grammar}')), if (depthFor(item).collocation.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('تركيب مهم: ${depthFor(item).collocation}'))]))),
    const SizedBox(height: 12), if (submitted) FilledButton(onPressed: () { if (pos + 1 >= items.length) { widget.onDone(); Navigator.pop(c); } else { setState(() { pos++; submitted = false; answer = ''; started = DateTime.now(); mode = plannedItems.isEmpty ? _fallbackMode(pos, sessionState) : _modeForPlanItem(plannedItems[pos]); }); } }, child: Text(pos + 1 >= items.length ? 'إنهاء الجلسة' : 'التالي')),
  ]));
}

class VocabularyV35 extends StatefulWidget {
  final LearnerRepository repo; final List<ContentItem> corpus; final VoidCallback onDone; final LanguagePresentation presentation; final LanguageContentQuality contentQuality; final LanguageTextNormalizer textNormalizer; final AppDependencies dependencies;
  const VocabularyV35({super.key, required this.repo, required this.corpus, required this.onDone, required this.presentation, required this.contentQuality, required this.textNormalizer, required this.dependencies});

  @override State<VocabularyV35> createState() => _VocabularyV35State();
}

class _VocabularyV35State extends State<VocabularyV35> {
  Set<String> _favorites = {};
  List<Map<String, dynamic>> _customEntries = [];
  String _filter = 'all';

  @override void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final favs = await widget.dependencies.favoritesRepository.getFavorites();
    final custom = await widget.dependencies.userVocabularyService.getCustomEntries();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _customEntries = custom;
      });
    }
  }

  void _showAddCustomDialog() {
    final germanController = TextEditingController();
    final arabicController = TextEditingController();
    final articleController = TextEditingController();
    final notesController = TextEditingController();
    final exampleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 16, right: 16, top: 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إضافة مفردة مخصصة', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: germanController,
                decoration: const InputDecoration(labelText: 'الكلمة بالألمانية', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: arabicController,
                decoration: const InputDecoration(labelText: 'الترجمة العربية', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: 'none',
                decoration: const InputDecoration(labelText: 'الأداة (اختياري)', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('بدون أداة')),
                  DropdownMenuItem(value: 'der', child: Text('der')),
                  DropdownMenuItem(value: 'die', child: Text('die')),
                  DropdownMenuItem(value: 'das', child: Text('das')),
                ],
                onChanged: (v) => articleController.text = v == 'none' ? '' : v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: exampleController,
                decoration: const InputDecoration(labelText: 'مثال (اختياري)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await widget.dependencies.userVocabularyService.addCustomEntry({
                      'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      'german_text': germanController.text,
                      'arabic_translation': arabicController.text,
                      'article': articleController.text,
                      'notes': notesController.text,
                      'example_sentence': exampleController.text,
                      'created_at': DateTime.now().toIso8601String(),
                      'is_custom': 1,
                    });
                    if (mounted) {
                      Navigator.pop(c);
                      _loadData();
                    }
                  }
                },
                child: const Text('حفظ'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('A1 • ${widget.corpus.length} وحدات تعلم')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('الكل')),
                ButtonSegment(value: 'favorites', label: Text('المفضلة')),
                ButtonSegment(value: 'custom', label: Text('مخصص')),
              ],
              selected: {_filter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _filter = newSelection.first);
              },
            ),
          ),
          Expanded(
            child: Builder(builder: (c) {
              if (_filter == 'custom') {
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _customEntries.length,
                  itemBuilder: (c, i) {
                    final e = _customEntries[i];
                    return Card(
                      child: ListTile(
                        title: Text(e['german_text'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(e['arabic_translation'] as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await widget.dependencies.userVocabularyService.deleteCustomEntry(e['id'] as String);
                            _loadData();
                          },
                        ),
                      ),
                    );
                  },
                );
              }

              final displayList = _filter == 'favorites'
                  ? widget.corpus.where((x) => _favorites.contains(x.id)).toList()
                  : widget.corpus;

              if (displayList.isEmpty) {
                return const Center(child: Text('القائمة فارغة.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: displayList.length,
                itemBuilder: (c, i) {
                  final x = displayList[i];
                  final d = depthFor(x);
                  final issues = widget.contentQuality.issues(x);
                  final isFav = _favorites.contains(x.id);

                  return Card(
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(x.sourceText, style: const TextStyle(fontWeight: FontWeight.w800))),
                          IconButton(
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                            onPressed: () async {
                              await widget.dependencies.favoritesRepository.toggleFavorite(x.id);
                              _loadData();
                            },
                          ),
                        ],
                      ),
                      subtitle: Text('${x.translationText} • ${x.topic}'),
                      children: [
                        ListTile(title: Text(x.exampleText), subtitle: Text(x.exampleTranslationText)),
                        if (x.grammaticalMarker.isNotEmpty) ListTile(title: Text('${widget.presentation.grammaticalMarkerLabel}: ${x.grammaticalMarker}'), subtitle: Text(x.pluralForm.isEmpty ? '' : '${widget.presentation.pluralLabel}: ${x.pluralForm}')),
                        if (d.collocation.isNotEmpty) ListTile(title: const Text('تركيب طبيعي'), subtitle: Text(d.collocation)),
                        if (d.grammar.isNotEmpty) ListTile(title: const Text('قاعدة مرتبطة'), subtitle: Text(d.grammar)),
                        if (issues.isNotEmpty) ListTile(title: Text('محجوب: ${issues.join(' • ')}')),
                        ListTile(leading: const Icon(Icons.play_circle_outline), title: const Text('تدرب من البداية إلى الاحتفاظ'), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => SingleItemSession(repo: widget.repo, item: x, onDone: widget.onDone, presentation: widget.presentation, textNormalizer: widget.textNormalizer))))
                      ]
                    )
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SingleItemSession extends StatefulWidget { final LearnerRepository repo; final ContentItem item; final VoidCallback onDone; final LanguagePresentation presentation; final LanguageTextNormalizer textNormalizer; const SingleItemSession({super.key, required this.repo, required this.item, required this.onDone, required this.presentation, required this.textNormalizer}); @override State<SingleItemSession> createState() => _SingleState(); }
class _SingleState extends State<SingleItemSession> {
  final SafeTtsController tts = SafeTtsController(); int step = 0; String answer = ''; bool done = false, correct = false; late DateTime start;
  final labels = const ['Recognize','Understand','Listen','Produce','Transfer','Retain'];
  @override void initState() { super.initState(); start = DateTime.now(); }
  String get expected { final d = depthFor(widget.item); if (step == 0) return widget.item.sourceText; if (step == 2) return widget.item.exampleText; if (step == 4 && d.transferAnswer.isNotEmpty) return d.transferAnswer; return widget.item.exampleText; }
  String get question { final d = depthFor(widget.item); switch (step) { case 0: return 'ما الكلمة بـ${widget.presentation.targetLanguageName}؟ ${widget.item.translationText}'; case 1: return 'اربط الكلمة بمعناها ثم اكتبها بـ${widget.presentation.targetLanguageName}.'; case 2: return 'استمع ثم اكتب الجملة.'; case 3: return d.transferPrompt.isNotEmpty ? d.transferPrompt : widget.item.exampleTranslationText; case 4: return d.transferPrompt.isNotEmpty ? d.transferPrompt : 'استخدم الكلمة في موقف جديد.'; default: return 'مراجعة متأخرة: اكتب ما تتذكره.'; } }
  Future<void> submit() async { final a = widget.textNormalizer.answer(answer); final e = widget.textNormalizer.answer(expected); correct = a == e || widget.item.acceptedForms.any((value) => widget.textNormalizer.answer(value) == a); final skills = ['recall','recall','listening','production','transfer','recall']; await widget.repo.record(item: widget.item, answer: answer, correct: correct, seconds: DateTime.now().difference(start).inSeconds.clamp(1, 999).toInt(), hinted: false, skillOverride: skills[step]); if (!mounted) return; setState(() => done = true); }
  Future<void> speak() => tts.speak( widget.item.exampleText);
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text('${labels[step]} • ${widget.item.sourceText}')), body: ListView(padding: const EdgeInsets.all(18), children: [LinearProgressIndicator(value: (step + 1) / labels.length), const SizedBox(height: 22), Text(question, style: Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), if (step == 2) Padding(padding: const EdgeInsets.only(top: 12), child: FilledButton.icon(onPressed: speak, icon: const Icon(Icons.volume_up), label: const Text('استمع'))), if (step == 1) Padding(padding: const EdgeInsets.only(top: 12), child: Text('المعنى: ${widget.item.translationText}')), const SizedBox(height: 15), TextField(enabled: !done, onChanged: (x) => answer = x, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: 'اكتب بـ${widget.presentation.targetLanguageName}', border: const OutlineInputBorder())), const SizedBox(height: 12), if (!done) FilledButton(onPressed: submit, child: const Text('تحقق')) else Card(child: ListTile(leading: Icon(correct ? Icons.check_circle : Icons.close), title: Text(correct ? 'أحسنت' : 'نحتاج دليلًا إضافيًا'), subtitle: Text('الإجابة: $expected'))), if (done) FilledButton(onPressed: () { if (step + 1 >= labels.length) { widget.onDone(); Navigator.pop(c); } else { setState(() { step++; done = false; answer = ''; start = DateTime.now(); }); } }, child: Text(step + 1 >= labels.length ? 'إنهاء' : 'التالي'))]));
}











class SmartAssessmentPage extends StatefulWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus; final LanguageExerciseStrategy exerciseStrategy; final LanguagePresentation presentation; final LanguageContentQuality contentQuality; final LanguageTextNormalizer textNormalizer; final LanguageContentIntelligence contentIntelligence;
  const SmartAssessmentPage({super.key, required this.repo, required this.corpus, required this.exerciseStrategy, required this.presentation, required this.contentQuality, required this.textNormalizer, required this.contentIntelligence});
  @override State<SmartAssessmentPage> createState() => _SmartAssessmentState();
}

class _SmartAssessmentState extends State<SmartAssessmentPage> {
  final SafeTtsController tts = SafeTtsController();
  late LearnerState assessmentState;
  late List<AssessmentQuestion> questions;
  final answers = <String,String>{};
  final responses = <AssessmentResponse>[];
  int index = 0;
  bool submitted = false;
  bool correct = false;
  bool saving = false;
  late DateTime started;

  @override void initState() {
    super.initState();
    _build();
  }

  void _build() {
    assessmentState = widget.repo.load();
    final corpus = widget.corpus;
    questions = AssessmentEngine.build(corpus, assessmentState, exerciseStrategy: widget.exerciseStrategy, isLearnable: widget.contentQuality.isLearnable, questionCount: 8, seed: DateTime.now().day + DateTime.now().month);
    if (questions.isEmpty) questions = const [];
    started = DateTime.now();
  }

  AssessmentQuestion get q => questions[index];
  String get _expected => q.expected;
  bool _matches(String value) {
    final a = assessmentNormalize(value);
    if (a.isEmpty) return false;
    return assessmentAnswerMatches(AssessmentResponse(questionId:q.id,itemId:q.itemId,answer:value,correct:true,hinted:false),q);
  }

  Future<void> _speak() => tts.speak(q.expected, rate: .42);

  Future<void> _submit() async {
    if (submitted) return;
    final answer = answers[q.id] ?? '';
    correct = _matches(answer);
    responses.add(AssessmentResponse(questionId:q.id,itemId:q.itemId,answer:answer,correct:correct,hinted:false));
    setState(() => submitted = true);
  }

  Future<void> _next() async {
    if(saving)return;
    if (saving || !mounted) return;
    if (index + 1 >= questions.length) {
      setState(() => saving = true);
      try {
        final corpus = widget.corpus;
        final result = AssessmentEngine.score(responses, corpus, exerciseStrategy: widget.exerciseStrategy);
        for (final response in responses) {
          final item = assessmentFindItem(corpus, response.itemId);
          if (item == null) continue;
          final question = AssessmentEngine.questionFor(item, response.questionId, widget.exerciseStrategy);
          await widget.repo.record(item: item, answer: response.answer, correct: response.correct, seconds: DateTime.now().difference(started).inSeconds.clamp(1, 999).toInt(), hinted: response.hinted, skillOverride: question.skill);
        }
        await widget.repo.recordAssessment(result);
        if (!mounted) return;
        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AssessmentResultPage(result: result, history: assessmentState.assessmentHistory)));
      } finally {
        if (mounted) setState(() => saving = false);
      }
      return;
    }
    setState(() { index++; submitted=false; correct=false; started=DateTime.now(); });
  }

  @override Widget build(BuildContext c) {
    if (questions.isEmpty) return Scaffold(appBar:AppBar(title:const Text('الاختبار الذكي')),body:const Center(child:Text('لا توجد أسئلة صالحة للاختبار حاليًا.')));
    return Scaffold(appBar:AppBar(title:Text('الاختبار الذكي ${index+1}/${questions.length}')),body:ListView(padding:const EdgeInsets.all(18),children:[
      LinearProgressIndicator(value:(index+1)/questions.length), const SizedBox(height:18),
      Chip(label:Text(_typeLabel(q.type))), const SizedBox(height:12),
      Text(q.prompt,style:Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),
      if(q.type==AssessmentQuestionType.listening) Padding(padding:const EdgeInsets.only(top:12),child:FilledButton.icon(onPressed:_speak,icon:const Icon(Icons.volume_up),label:const Text('استمع'))),
      const SizedBox(height:14), TextField(enabled:!submitted,onChanged:(v)=>answers[q.id]=v,textDirection:TextDirection.ltr,minLines:1,maxLines:3,decoration:InputDecoration(border:const OutlineInputBorder(),labelText:'إجابتك بـ${widget.presentation.targetLanguageName}')),
      const SizedBox(height:12),
      if(!submitted) FilledButton(onPressed:_submit,child:const Text('تحقق')) else Card(child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(correct?'✓ إجابة صحيحة':'✗ تحتاج مراجعة',style:Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:5),Text('الإجابة المستهدفة: $_expected')]))),
      if(submitted) Padding(padding:const EdgeInsets.only(top:12),child:FilledButton(onPressed:_next,child:Text(index+1>=questions.length?'عرض النتيجة':'التالي'))),
    ]));
  }

  @override void dispose(){tts.dispose();super.dispose();}

  static String _typeLabel(AssessmentQuestionType t) => const {AssessmentQuestionType.recall:'التعرّف',AssessmentQuestionType.grammar:'القواعد',AssessmentQuestionType.translation:'الترجمة',AssessmentQuestionType.listening:'الاستماع',AssessmentQuestionType.production:'الإنتاج'}[t] ?? 'غير معروف';
}

class AssessmentResultPage extends StatelessWidget {
  final AssessmentResult result;
  final List<AssessmentHistory> history;
  const AssessmentResultPage({super.key,required this.result,required this.history});
  @override Widget build(BuildContext c) => Scaffold(appBar:AppBar(title:const Text('نتيجة الاختبار')),body:ListView(padding:const EdgeInsets.all(18),children:[
    Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[Text('${result.score.round()}%',style:Theme.of(c).textTheme.displaySmall?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:6),Text('${result.correct}/${result.answered} إجابات صحيحة • ${result.cleanCorrect} دون تلميح'),const SizedBox(height:8),Text(_message(result.score))]))),
    const SizedBox(height:14),Text('خريطة المهارات',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900)),
    ...result.skillScores.entries.map((e)=>ListTile(title:Text(e.key),subtitle:LinearProgressIndicator(value:e.value),trailing:Text('${(e.value*100).round()}%'))),
    const SizedBox(height:8),
    if(result.weakSkills.isNotEmpty) Card(child:ListTile(leading:const Icon(Icons.warning_amber_outlined),title:const Text('ما الذي نركز عليه؟'),subtitle:Text(result.weakSkills.join(' • ')))),
    if(result.nextReviewItemIds.isNotEmpty) Card(child:ListTile(leading:const Icon(Icons.replay_outlined),title:const Text('بطاقات تستحق المراجعة'),subtitle:Text('${result.nextReviewItemIds.length} عناصر ستعود إلى خطة المراجعة.'))),
    const SizedBox(height:12),Text('آخر الاختبارات',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900)),
    ...history.take(5).map((h)=>ListTile(title:Text('${h.score.round()}%'),subtitle:Text('${h.at.toLocal()} • ${h.weakSkills.isEmpty?'لا توجد نقاط ضعف محددة':h.weakSkills.join('، ')}'))),
  ]));
  static String _message(double score)=>score>=85?'ممتاز. سنرفع التحدي ونركز على الاحتفاظ.':score>=70?'جيد. هناك مهارات تحتاج تثبيتًا إضافيًا.':'النتيجة تكشف نقاطًا تحتاج علاجًا؛ سنحوّلها إلى مراجعات مستهدفة.';
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
          leading: Icon(premium ? Icons.workspace_premium : Icons.lock_open_outlined),
          title: Text(premium ? 'Premium مفعّل' : 'الخطة المجانية'),
          subtitle: Text(premium ? 'كل مزايا التعلم المتقدمة متاحة لك.' : 'جرّب الأساسيات مجانًا، واطّلع على الباقات المدفوعة للمزايا المتقدمة.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => SubscriptionPage(repo: null))),
        ),
      );
    },
  );
}

