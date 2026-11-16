import 'package:flutter/material.dart';

import '../ui_v35/safe_ui.dart';

import '../models/content.dart';
import '../models/learner.dart';
import '../services/repository.dart';
import '../bootstrap/production_bootstrap.dart';
import '../services/preferences_service.dart';
import '../services/learner_persistence.dart';
import '../services/mastery_dashboard.dart';
import '../language/language_content_intelligence.dart';
import '../services/teacher.dart';
import '../services/stats.dart';
import '../services/release.dart';
import '../services/ai_contract.dart';
import '../services/app_dependencies.dart';

class DeutschApp extends StatefulWidget {
  final LearnerRepository repo;
  final AppDependencies<ContentItem> dependencies;
  const DeutschApp(this.repo, {required this.dependencies, super.key});

  @override
  State<DeutschApp> createState() => _AppState();
}

class _AppState extends State<DeutschApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Deutsch بالعربي',
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
        ),
        home: Home(
          repo: widget.repo,
          dependencies: widget.dependencies,
          onTheme: () => setState(() => dark = !dark),
        ),
      );
}

class Home extends StatefulWidget {
  final LearnerRepository repo;
  final AppDependencies<ContentItem> dependencies;
  final VoidCallback onTheme;

  const Home({
    super.key,
    required this.repo,
    required this.dependencies,
    required this.onTheme,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late LearnerState state;

  @override
  void initState() {
    super.initState();
    state = widget.repo.load();
  }

  void refresh() {
    if (!mounted) return;
    setState(() => state = widget.repo.load());
  }

  @override
  Widget build(BuildContext context) {
    final decision = Teacher.decide(state);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deutsch بالعربي'),
        actions: [
          IconButton(
            onPressed: widget.onTheme,
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(repo: widget.repo),
              ),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          Text(
            'مرحبًا 👋',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text('مدرسك يختار لك الخطوة التالية بناءً على أدائك الفعلي.'),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أفضل خطوة الآن',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    decision.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(decision.reason),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LearningSession(
                            repo: widget.repo,
                            dependencies: widget.dependencies,
                            onDone: refresh,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('ابدأ الآن'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'دليل التعلم',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          _proofRow(context, 'Recognize', Stats.score(state, 'recall')),
          _proofRow(context, 'Listen', Stats.score(state, 'listening')),
          _proofRow(context, 'Produce', Stats.score(state, 'production')),
          _proofRow(context, 'Transfer', Stats.score(state, 'transfer')),
          _proofRow(
            context,
            'Retain',
            state.review.isEmpty && state.learned.isNotEmpty ? 0.8 : 0.0,
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('ملخصك'),
              subtitle: Text(
                '${state.learned.length} كلمة • ${state.attempts.length} محاولة • '
                '${state.review.length} للمراجعة • متوسط ${Stats.avgSeconds(state)} ث',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProgressPage(state: state)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabularyPage(
                  repo: widget.repo,
                  dependencies: widget.dependencies,
                  onDone: refresh,
                ),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('استكشف مفردات A1'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    VerbPage(verbIndex: widget.dependencies.verbIndex),
              ),
            ),
            icon: const Icon(Icons.spellcheck_outlined),
            label: const Text('الأفعال والتصريف والماضي'),
          ),
        ],
      ),
    );
  }

  Widget _proofRow(BuildContext context, String name, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(width: 92, child: Text(name)),
            Expanded(child: LinearProgressIndicator(value: value)),
            const SizedBox(width: 10),
            Text('${(value * 100).round()}%'),
          ],
        ),
      );
}

class LearningSession extends StatefulWidget {
  final LearnerRepository repo;
  final AppDependencies<ContentItem> dependencies;
  final VoidCallback onDone;

  const LearningSession({
    super.key,
    required this.repo,
    required this.dependencies,
    required this.onDone,
  });

  @override
  State<LearningSession> createState() => _SessionState();
}

class _SessionState extends State<LearningSession> {
  int i = 0;
  String answer = '';
  bool submitted = false;
  bool correct = false;
  late DateTime started;
  late List<int> order;
  late final List<ContentItem> content;

  @override
  void initState() {
    super.initState();
    content = widget.dependencies.corpus;
    started = DateTime.now();
    final learned = widget.repo.load().learned;
    order = List.generate(
      content.length,
      (x) => x,
    ).where((x) => !learned.contains(content[x].id)).toList();
    if (order.isEmpty) {
      order = List.generate(content.length, (x) => x);
    }
    order = order.take(8).toList();
  }

  ContentItem get item => content[order[i % order.length]];

  Future<void> submit() async {
    if (submitted) return;
    String norm(String value) =>
        value.toLowerCase().replaceAll(RegExp(r'[.!?]'), '').trim();
    correct = item.acceptedForms.isEmpty
        ? norm(answer) == norm(item.sourceText)
        : item.acceptedForms.map(norm).contains(norm(answer));
    await widget.repo.record(
      item: item,
      answer: answer,
      correct: correct,
      seconds:
          DateTime.now().difference(started).inSeconds.clamp(1, 999).toInt(),
      hinted: false,
    );
    if (!mounted) return;
    setState(() => submitted = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('جلسة ${i + 1}/${order.length}')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(item.topic, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              item.translationText,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(item.exampleText,
                style: Theme.of(context).textTheme.titleLarge),
            Text(item.exampleTranslationText),
            const SizedBox(height: 18),
            TextField(
              enabled: !submitted,
              onChanged: (x) => answer = x,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText:
                    'اكتب بـ${widget.dependencies.languagePack.presentation.targetLanguageName}',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!submitted)
              FilledButton(onPressed: submit, child: const Text('تحقق'))
            else
              Card(
                child: ListTile(
                  leading: Icon(correct ? Icons.check_circle : Icons.close),
                  title: Text(correct ? 'أحسنت!' : 'ليس بعد'),
                  subtitle: Text(
                    correct
                        ? 'إجابة صحيحة.'
                        : 'الإجابة المستهدفة: ${item.sourceText}',
                  ),
                ),
              ),
            if (submitted)
              FilledButton(
                onPressed: () {
                  if (i + 1 >= order.length) {
                    widget.onDone();
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      i++;
                      submitted = false;
                      answer = '';
                      started = DateTime.now();
                    });
                  }
                },
                child: Text(i + 1 >= order.length ? 'إنهاء الجلسة' : 'التالي'),
              ),
          ],
        ),
      );
}

class VocabularyPage extends StatefulWidget {
  final LearnerRepository repo;
  final AppDependencies<ContentItem> dependencies;
  final VoidCallback onDone;

  const VocabularyPage({
    super.key,
    required this.repo,
    required this.dependencies,
    required this.onDone,
  });

  @override
  State<VocabularyPage> createState() => _VocabState();
}

class _VocabState extends State<VocabularyPage> {
  final SafeTtsController tts = SafeTtsController();
  late final List<ContentItem> content;

  @override
  void initState() {
    super.initState();
    content = widget.dependencies.corpus;
  }

  Future<void> speak(String text) => tts.speak(text);

  @override
  void dispose() {
    tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('A1 • ${content.length} مدخلًا')),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: content.length,
          itemBuilder: (context, i) {
            final item = content[i];
            final issues =
                widget.dependencies.languagePack.contentQuality.issues(
              item,
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.sourceText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: widget.dependencies.languagePack.presentation
                              .pronunciationTooltip,
                          onPressed: () => speak(item.sourceText),
                          icon: const Icon(Icons.volume_up_outlined),
                        ),
                      ],
                    ),
                    Text(
                      item.translationText,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (item.grammaticalMarker.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${widget.dependencies.languagePack.presentation.grammaticalMarkerLabel}: '
                          '${item.grammaticalMarker}'
                          '${item.pluralForm.isEmpty ? '' : ' • ${widget.dependencies.languagePack.presentation.pluralLabel}: ${item.pluralForm}'}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    const Divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.exampleText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'نطق الجملة',
                          onPressed: () => speak(item.exampleText),
                          icon: const Icon(Icons.volume_up_outlined),
                        ),
                      ],
                    ),
                    Text(item.exampleTranslationText),
                    if (issues.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'مراجعة: ${issues.join(' • ')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}

class VerbPage extends StatefulWidget {
  final VerbIndex verbIndex;
  const VerbPage({super.key, required this.verbIndex});

  @override
  State<VerbPage> createState() => _VerbPageState();
}

class _VerbPageState extends State<VerbPage> {
  final SafeTtsController tts = SafeTtsController();
  late LearnerState state;
  late final Future<LearnerRepository> _repoFuture;
  late final Future<LearnerState> _stateFuture;

  @override
  void initState() {
    super.initState();
    state = LearnerState(updatedAt: DateTime.now());
    _repoFuture = PreferencesService.instance().then(
      (prefs) => bindVerifiedLearnerState(prefs: prefs),
    );
    _stateFuture = _repoFuture.then((repo) => repo.load());
  }

  Future<void> speak(String text) => tts.speak(text);

  Future<void> _toggleFavorite(String infinitive, {bool close = false}) async {
    final repo = await _repoFuture;
    await repo.toggleFavoriteVerb(infinitive);
    if (!mounted) return;
    setState(() => state = repo.load());
    if (close && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LearnerState>(
        future: _stateFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          state = snapshot.data!;
          final catalog = widget.verbIndex;
          final byGroup = catalog.groups;
          final favorites = state.favoriteVerbs;
          return Scaffold(
            appBar: AppBar(
              title: Text('الأفعال • ${catalog.infinitives.length} فعل'),
              actions: [
                IconButton(
                  tooltip: 'أفعالي المفضلة',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            '⭐ أفعال أريد دراستها',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          ...favorites.map(
                            (favorite) => ListTile(
                              title: Text(favorite),
                              trailing: IconButton(
                                onPressed: () =>
                                    _toggleFavorite(favorite, close: true),
                                icon:
                                    const Icon(Icons.star, color: Colors.amber),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.star_border),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'كل ضمير مستقل: ich، du، er، sie (هي)، es، wir، ihr، sie (هم)، Sie. '
                      'كل تصريف يحتوي على الحاضر + الماضي + مثالين مترجمين.',
                    ),
                  ),
                ),
                ...byGroup.entries.map(
                  (group) => Card(
                    child: ExpansionTile(
                      title: Text(
                        group.key,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('${group.value.toSet().length} أفعال'),
                      children: group.value.toSet().map((infinitive) {
                        final rows = catalog.rowsFor(infinitive);
                        final favorite = favorites.contains(infinitive);
                        if (rows.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        infinitive,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _toggleFavorite(infinitive),
                                      icon: Icon(
                                        favorite
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: favorite ? Colors.amber : null,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'نطق الفعل',
                                      onPressed: () => speak(infinitive),
                                      icon: const Icon(
                                        Icons.volume_up_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                                ...rows.map(
                                  (verb) => Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${verb.person} — ${verb.personAr}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'نطق التصريف',
                                              onPressed: () => speak(verb.form),
                                              icon: const Icon(
                                                Icons.volume_up_outlined,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text('الحاضر: ${verb.form}'),
                                        Text(
                                          'الماضي: ${verb.past} — ${verb.pastArabic}',
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(child: Text(verb.example)),
                                            IconButton(
                                              tooltip: 'نطق المثال',
                                              onPressed: () =>
                                                  speak(verb.example),
                                              icon: const Icon(
                                                Icons.volume_up_outlined,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(verb.exampleAr),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(verb.pastExample),
                                            ),
                                            IconButton(
                                              tooltip: 'نطق مثال الماضي',
                                              onPressed: () =>
                                                  speak(verb.pastExample),
                                              icon: const Icon(
                                                Icons.volume_up_outlined,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(verb.pastExampleAr),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class ProgressPage extends StatelessWidget {
  final LearnerState state;
  const ProgressPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('تقدمك')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Skill Passport',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _row('Vocabulary', state.learned.length / 50),
            _row('Grammar / Recall', Stats.score(state, 'recall')),
            _row('Listening', Stats.score(state, 'listening')),
            _row('Production', Stats.score(state, 'production')),
            _row('Transfer', Stats.score(state, 'transfer')),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                title: Text(
                  state.learned.length >= 40
                      ? 'إنجاز قوي'
                      : 'الملف ما زال قيد البناء',
                ),
                subtitle: Text(
                  state.learned.length >= 40
                      ? 'لديك دليل تعلم متنوع.'
                      : 'نحتاج مزيدًا من الأدلة قبل إصدار شهادة إتقان.',
                ),
              ),
            ),
          ],
        ),
      );

  Widget _row(String name, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            SizedBox(width: 130, child: Text(name)),
            Expanded(
              child:
                  LinearProgressIndicator(value: value.clamp(0, 1).toDouble()),
            ),
            const SizedBox(width: 8),
            Text('${(value.clamp(0, 1).toDouble() * 100).round()}%'),
          ],
        ),
      );
}

class SettingsPage extends StatelessWidget {
  final LearnerRepository repo;
  const SettingsPage({super.key, required this.repo});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الإعدادات والخصوصية')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Card(
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('الخصوصية أولًا'),
                subtitle: Text(
                  'التقدم والمحاولات محفوظة محليًا في هذا الإصدار. '
                  'لا يوجد AI سحابي أو مزامنة سحابية مفعلة.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.cloud_off_outlined),
                title: Text('Offline'),
                subtitle: Text(
                  'المفردات، الجلسات، التقدم وTTS تعمل دون حساب سحابي.',
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('AI Teacher'),
                subtitle: Text(AiTeacherContract.rules.join('\n')),
              ),
            ),
            const SizedBox(height: 12),
            if (adminToolsEnabled)
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QualityPage()),
                ),
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('مركز الجودة والإصدار'),
              ),
          ],
        ),
      );
}

class QualityPage extends StatelessWidget {
  const QualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final failed = releaseGates.where((x) => !x.passed).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Quality & Release Center')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'حالة المنتج',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text('$failed بوابات ما زالت غير مكتملة.'),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          const Text(
            'قاعدة الإصدار: لا نعلن عن ميزة كأنها مكتملة إذا كانت مجرد Prototype.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final summary = MasteryDashboard.build(
      repo.load(),
      corpus: corpus,
      contentIntelligence: contentIntelligence,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الإتقان الذكية')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'جاهزية الإتقان',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          LinearProgressIndicator(value: summary.readiness),
          const SizedBox(height: 12),
          Text(
            '${(summary.readiness * 100).round()}% • ${summary.readinessLabel}',
          ),
          Text('الخطوة التالية: ${summary.actionLabel}'),
          Text('قابلية الاسترجاع: ${(summary.retrievability * 100).round()}%'),
          Text('خطر النسيان: ${(summary.retentionRisk * 100).round()}%'),
          Text(
            'مستحق للمراجعة: ${summary.dueItems} • متأخر: ${summary.overdueItems}',
          ),
        ],
      ),
    );
  }
}
