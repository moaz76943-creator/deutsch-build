import 'package:flutter/material.dart';

import '../language/language_exercise_strategy.dart';
import '../language/language_presentation.dart';
import '../core/safe_runtime.dart';
import '../models/conversation.dart';
import '../services/writing_analyzer.dart';
import '../services/repository.dart';
import '../language/language_text_normalizer.dart';
import '../services/speech_service.dart';
import '../services/ai_gateway.dart';
import '../services/privacy_settings.dart';
import '../services/conversation_engine.dart';
import 'safe_ui.dart';

class WritingCoachPage extends StatefulWidget {
  final LearnerRepository repo;
  final VoidCallback onDone;
  final LanguageTextNormalizer textNormalizer;
  final AiGateway aiGateway;
  final PrivacySettingsStore privacySettings;
  const WritingCoachPage({
    super.key,
    required this.repo,
    required this.onDone,
    required this.textNormalizer,
    required this.aiGateway,
    required this.privacySettings,
  });
  @override
  State<WritingCoachPage> createState() => _WritingCoachState();
}

class _WritingCoachState extends State<WritingCoachPage> {
  String text = '';
  String feedback = '';
  bool checked = false, loading = false;
  Future<void> check() async {
    final t = text.trim();
    final issues = <String>[
      for (final issue in WritingAnalyzer.analyze(
        t,
        textNormalizer: widget.textNormalizer,
      ))
        issue.message,
    ];
    if (issues.isEmpty) {
      final cloud = await widget.privacySettings.cloudAiEnabled();
      if (cloud && widget.aiGateway.enabled) {
        setState(() => loading = true);
        try {
          final result = await widget.aiGateway.reviewWriting(t);
          if (!mounted) return;
          setState(
            () => feedback = (result.corrected.isEmpty
                    ? ''
                    : 'التصحيح المقترح: ${result.corrected}\n') +
                (result.issues.isEmpty
                    ? 'لا توجد مشكلات واضحة.'
                    : result.issues.join('\n')) +
                '\n' +
                result.explanation,
          );
          return;
        } catch (_) {
          issues.add('تعذر الوصول إلى المراجعة السحابية؛ عُدنا للفحص المحلي.');
        } finally {
          if (mounted) setState(() => loading = false);
        }
      }
    }
    if (!mounted) return;
    for (final issue in issues.where((x) => !x.startsWith('اكتب جملة'))) {
      await widget.repo.recordWritingMistake(issue: issue);
    }
    setState(() {
      checked = true;
      feedback = issues.isEmpty
          ? 'الجملة تبدو سليمة مبدئيًا. يمكنك تفعيل AI السحابي اختياريًا للحصول على شرح أعمق.'
          : issues.join('\n');
      loading = false;
    });
    widget.onDone();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('تصحيح الكتابة')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'فحص محلي أولًا. أخطاء الكتابة تدخل الآن في مدرب الأخطاء حتى تتحول إلى تدريب علاجي.',
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (v) => text = v,
              textDirection: TextDirection.ltr,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'الجملة بالألمانية',
                hintText: 'Ich lerne Deutsch.',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: loading ? null : check,
              icon: Icon(loading ? Icons.hourglass_top : Icons.check),
              label: Text(loading ? 'جارٍ الفحص' : 'افحص الجملة'),
            ),
            if (checked || feedback.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(feedback),
                ),
              ),
          ],
        ),
      );
}

class ConversationPage extends StatefulWidget {
  final LearnerRepository repo;
  final VoidCallback onDone;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageTextNormalizer textNormalizer;
  final AiGateway aiGateway;
  final PrivacySettingsStore privacySettings;
  const ConversationPage({
    super.key,
    required this.repo,
    required this.onDone,
    required this.exerciseStrategy,
    required this.presentation,
    required this.textNormalizer,
    required this.aiGateway,
    required this.privacySettings,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('المحادثة')),
        body: Builder(
          builder: (BuildContext context) {
            final scenarios = ConversationEngine(
              exerciseStrategy: widget.exerciseStrategy,
              textNormalizer: widget.textNormalizer,
            ).scenarios;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: scenarios.length + 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.record_voice_over_outlined),
                      title: const Text('محادثة صوتية واقعية'),
                      subtitle: Text(
                        widget.presentation.conversation
                            .targetLanguageInstruction,
                      ),
                    ),
                  );
                }
                if (index == 1) {
                  return const SizedBox(height: 8);
                }
                if (index == scenarios.length + 2) {
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          c,
                          MaterialPageRoute(
                            builder: (_) => AiConversationPage(
                              scenario: 'محادثة عامة',
                              aiGateway: widget.aiGateway,
                              privacySettings: widget.privacySettings,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text('المحادثة النصية مع AI الاختياري'),
                      ),
                    ],
                  );
                }
                final scenarioIndex = index - 2;
                final x = scenarios[scenarioIndex];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.forum_outlined),
                    title: Text(x.title),
                    subtitle: Text('${x.situation}\n${x.turns.length} جولات'),
                    isThreeLine: true,
                    onTap: () => Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => VoiceConversationPage(
                          repo: widget.repo,
                          onDone: widget.onDone,
                          scenario: x,
                          exerciseStrategy: widget.exerciseStrategy,
                          presentation: widget.presentation,
                          textNormalizer: widget.textNormalizer,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
}

class VoiceConversationPage extends StatefulWidget {
  final LearnerRepository repo;
  final VoidCallback onDone;
  final ConversationScenario? scenario;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguagePresentation presentation;
  final LanguageTextNormalizer textNormalizer;
  const VoiceConversationPage({
    super.key,
    required this.repo,
    required this.onDone,
    required this.exerciseStrategy,
    required this.presentation,
    required this.textNormalizer,
    this.scenario,
  });
  @override
  State<VoiceConversationPage> createState() => _VoiceConversationState();
}

class _VoiceConversationState extends State<VoiceConversationPage> {
  final SpeechService speech = SpeechService();
  final SafeTtsController tts = SafeTtsController();
  late ConversationScenario scenario;
  int turnIndex = 0;
  String heard = '';
  String status = '';
  bool listening = false, scored = false;
  bool saving = false;
  bool speechBusy = false;
  ConversationScore? score;
  final scores = <ConversationScore>[];

  ConversationTurn get turn => scenario.turns.isEmpty
      ? widget.presentation.conversation.fallbackScenario.turns.first
      : scenario.turns[turnIndex.clamp(0, scenario.turns.length - 1)];

  ConversationScenario _safeScenario(ConversationScenario? candidate) {
    if (candidate != null && candidate.turns.isNotEmpty) return candidate;
    for (final item in ConversationEngine(
      exerciseStrategy: widget.exerciseStrategy,
      textNormalizer: widget.textNormalizer,
    ).scenarios) {
      if (item.turns.isNotEmpty) return item;
    }
    return widget.presentation.conversation.fallbackScenario;
  }

  @override
  void initState() {
    super.initState();
    scenario = _safeScenario(widget.scenario);
    status = widget.presentation.conversation.defaultSpeechStatus;
    _speakPrompt();
  }

  Future<void> _speakPrompt() => tts.speak(turn.promptGerman, rate: .43);

  Future<void> _toggleListening() async {
    if (speechBusy) return;
    if (scored || saving) return;
    speechBusy = true;
    try {
      if (listening) {
        await speech.stop();
        if (mounted) setState(() => listening = false);
        return;
      }
      if (mounted) setState(() => status = 'أستمع... تحدث بجملة كاملة.');
      final ok = await speech.listen(
        onResult: (r) {
          if (!mounted) return;
          setState(() => heard = r.recognizedWords);
          if (r.finalResult) {
            speech.stop();
            if (mounted) setState(() => listening = false);
          }
        },
      );
      if (mounted) setState(() => listening = ok);
      if (!ok && mounted)
        setState(
          () => status = widget.presentation.conversation.speechPermissionError,
        );
    } finally {
      speechBusy = false;
    }
  }

  Future<void> _score() async {
    if (scored || saving) return;
    if (listening) {
      await speech.stop();
      if (!mounted) return;
      setState(() => listening = false);
    }
    final value = ConversationEngine(
      exerciseStrategy: widget.exerciseStrategy,
      textNormalizer: widget.textNormalizer,
    ).score(turn, heard);
    setState(() {
      score = value;
      scored = true;
      status = value.correct
          ? 'إجابة جيدة. انتقل للجولة التالية.'
          : 'اقتربت. راجع الكلمات الناقصة ثم أعد المحاولة أو تابع.';
    });
    await widget.repo.recordConversationAttempt(
      itemId: turn.id,
      skill: turn.skill,
      answer: heard,
      correct: value.correct,
      seconds: 20,
      hinted: false,
    );
    if (!mounted) return;
    widget.onDone();
  }

  void _retry() {
    setState(() {
      heard = '';
      score = null;
      scored = false;
      status = 'استمع للسؤال ثم أجب من جديد.';
    });
    _speakPrompt();
  }

  void _next() {
    final currentScore = score;
    if (!scored || currentScore == null || saving || !mounted) return;
    if (turnIndex + 1 >= scenario.turns.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceConversationResultPage(
            scenario: scenario,
            scores: List.of(scores)..add(currentScore),
            onDone: widget.onDone,
          ),
        ),
      );
      return;
    }
    setState(() {
      scores.add(currentScore);
      turnIndex++;
      heard = '';
      score = null;
      scored = false;
      status = widget.presentation.conversation.defaultSpeechStatus;
    });
    _speakPrompt();
  }

  @override
  void dispose() {
    speech.dispose();
    tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final currentScore = score;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${scenario.title} • ${turnIndex + 1}/${scenario.turns.length}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          LinearProgressIndicator(
            value: (turnIndex + 1) / scenario.turns.length,
          ),
          const SizedBox(height: 18),
          Text('الموقف', style: Theme.of(c).textTheme.labelLarge),
          Text(
            scenario.situation,
            style: Theme.of(c)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الطرف الآخر', style: Theme.of(c).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    turn.promptGerman,
                    textDirection: TextDirection.ltr,
                    style: Theme.of(c)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(turn.promptArabic),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'استمع للجملة',
                      onPressed: _speakPrompt,
                      icon: const Icon(Icons.volume_up_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    heard.isEmpty ? 'لم يتم التقاط كلامك بعد.' : heard,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(status),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: scored ? null : _toggleListening,
                    icon: Icon(listening ? Icons.stop : Icons.mic),
                    label: Text(
                      listening
                          ? 'إيقاف التسجيل'
                          : 'تحدث ${widget.presentation.conversation.targetLanguageName}',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: (!listening &&
                            heard.trim().isNotEmpty &&
                            !scored &&
                            !saving)
                        ? _score
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('قيّم الإجابة'),
                  ),
                ],
              ),
            ),
          ),
          if (scored && currentScore != null) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentScore.value}%',
                      style: Theme.of(c)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      currentScore.correct
                          ? 'المعنى الأساسي وصل بشكل جيد.'
                          : 'المعنى لم يكتمل بعد.',
                    ),
                    if (currentScore.matchedKeywords.isNotEmpty)
                      Text(
                        'تم التقاط: ${currentScore.matchedKeywords.join(' • ')}',
                      ),
                    if (currentScore.missingKeywords.isNotEmpty)
                      Text(
                        'تحتاج: ${currentScore.missingKeywords.join(' • ')}',
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'النموذج: ${safeFirst(turn.expected) ?? 'لا يوجد نموذج متاح'}',
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _retry,
                    child: const Text('أعد المحاولة'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(
                      turnIndex + 1 >= scenario.turns.length
                          ? 'النتيجة'
                          : 'التالي',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'التقييم محلي: لا يتم إرسال تسجيلك أو النص إلى خادم AI. جودة التعرف تعتمد على محرك الكلام في الجهاز.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class VoiceConversationResultPage extends StatelessWidget {
  final ConversationScenario scenario;
  final List<ConversationScore> scores;
  final VoidCallback onDone;
  const VoiceConversationResultPage({
    super.key,
    required this.scenario,
    required this.scores,
    required this.onDone,
  });
  @override
  Widget build(BuildContext c) {
    final total = scores.fold<int>(0, (a, b) => a + b.value);
    final average = scores.isEmpty ? 0 : (total / scores.length).round();
    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة المحادثة')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(
                    '$average%',
                    style: Theme.of(c)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${scores.where((x) => x.correct).length}/${scores.length} جولات ناجحة',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    average >= 85
                        ? 'ممتاز. يمكنك رفع صعوبة الموقف.'
                        : average >= 67
                            ? 'جيد. أعد الجولات الضعيفة مرة أخرى.'
                            : 'سنحوّل الكلمات الناقصة إلى تدريب علاجي.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...scores.asMap().entries.map(
                (e) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${e.key + 1}')),
                    title: Text('${e.value.value}%'),
                    subtitle: Text(
                      e.value.missingKeywords.isEmpty
                          ? 'لا توجد كلمات ناقصة.'
                          : 'تحتاج: ${e.value.missingKeywords.join(' • ')}',
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.pop(c),
            icon: const Icon(Icons.mic),
            label: const Text('العودة إلى المحادثات'),
          ),
        ],
      ),
    );
  }
}

class AiConversationPage extends StatefulWidget {
  final String scenario;
  final AiGateway aiGateway;
  final PrivacySettingsStore privacySettings;
  const AiConversationPage({
    super.key,
    required this.scenario,
    required this.aiGateway,
    required this.privacySettings,
  });
  @override
  State<AiConversationPage> createState() => _AiConversationState();
}

class _AiConversationState extends State<AiConversationPage> {
  final input = TextEditingController();
  final messages = <String>[];
  bool loading = false;
  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || loading) return;
    setState(() {
      messages.add('أنت: $text');
      input.clear();
      loading = true;
    });
    try {
      final enabled = await widget.privacySettings.cloudAiEnabled();
      if (enabled && widget.aiGateway.enabled) {
        try {
          final reply = await widget.aiGateway.continueConversation(
            scenario: widget.scenario,
            message: text,
          );
          if (mounted) setState(() => messages.add('المدرس: $reply'));
        } catch (_) {
          if (mounted)
            setState(
              () => messages.add(
                'المدرس: تعذر الاتصال الآن. أكمل بالمحتوى المحلي أو حاول لاحقًا.',
              ),
            );
        }
      } else {
        if (mounted)
          setState(
            () => messages.add(
              'المدرس: الوضع المحلي لا يحتاج إنترنت. اختر جملة من أمثلة الموقف وجرّب إعادة صياغتها.',
            ),
          );
      }
    } catch (_) {
      if (mounted)
        setState(
          () => messages.add('المدرس: تعذر قراءة إعدادات الاتصال الآن.'),
        );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text(widget.scenario)),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: messages.length,
                itemBuilder: (_, i) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(messages[i], textDirection: TextDirection.ltr),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ردك بالألمانية',
                        hintText: 'اكتب ردك بالألمانية',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'إرسال الرسالة إلى المدرس',
                    onPressed: loading ? null : send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
