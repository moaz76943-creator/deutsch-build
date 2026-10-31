part of '../learning_pages.dart';

class SingleItemSession extends StatefulWidget {
  final LearnerRepository repo;
  final ContentItem item;
  final VoidCallback onDone;
  final LanguagePresentation presentation;
  final LanguageTextNormalizer textNormalizer;
  const SingleItemSession({
    super.key,
    required this.repo,
    required this.item,
    required this.onDone,
    required this.presentation,
    required this.textNormalizer,
  });
  @override
  State<SingleItemSession> createState() => _SingleState();
}

class _SingleState extends State<SingleItemSession> {
  final SafeTtsController tts = SafeTtsController();
  int step = 0;
  String answer = '';
  bool done = false, correct = false;
  late DateTime start;
  final labels = const [
    'Recognize',
    'Understand',
    'Listen',
    'Produce',
    'Transfer',
    'Retain',
  ];
  @override
  void initState() {
    super.initState();
    start = DateTime.now();
  }

  String get expected {
    final d = depthFor(widget.item);
    if (step == 0) return widget.item.sourceText;
    if (step == 2) return widget.item.exampleText;
    if (step == 4 && d.transferAnswer.isNotEmpty) return d.transferAnswer;
    return widget.item.exampleText;
  }

  String get question {
    final d = depthFor(widget.item);
    switch (step) {
      case 0:
        return 'ما الكلمة بـ${widget.presentation.targetLanguageName}؟ ${widget.item.translationText}';
      case 1:
        return 'اربط الكلمة بمعناها ثم اكتبها بـ${widget.presentation.targetLanguageName}.';
      case 2:
        return 'استمع ثم اكتب الجملة.';
      case 3:
        return d.transferPrompt.isNotEmpty
            ? d.transferPrompt
            : widget.item.exampleTranslationText;
      case 4:
        return d.transferPrompt.isNotEmpty
            ? d.transferPrompt
            : 'استخدم الكلمة في موقف جديد.';
      default:
        return 'مراجعة متأخرة: اكتب ما تتذكره.';
    }
  }

  Future<void> submit() async {
    final a = widget.textNormalizer.answer(answer);
    final e = widget.textNormalizer.answer(expected);
    correct = a == e ||
        widget.item.acceptedForms.any(
          (value) => widget.textNormalizer.answer(value) == a,
        );
    final skills = [
      'recall',
      'recall',
      'listening',
      'production',
      'transfer',
      'recall',
    ];
    await widget.repo.record(
      item: widget.item,
      answer: answer,
      correct: correct,
      seconds: DateTime.now().difference(start).inSeconds.clamp(1, 999).toInt(),
      hinted: false,
      skillOverride: skills[step],
    );
    if (!mounted) return;
    setState(() => done = true);
  }

  Future<void> speak() => tts.speak(widget.item.exampleText);
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar:
            AppBar(title: Text('${labels[step]} • ${widget.item.sourceText}')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            LinearProgressIndicator(value: (step + 1) / labels.length),
            const SizedBox(height: 22),
            Text(
              question,
              style: Theme.of(c)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (step == 2)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton.icon(
                  onPressed: speak,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('استمع'),
                ),
              ),
            if (step == 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('المعنى: ${widget.item.translationText}'),
              ),
            const SizedBox(height: 15),
            TextField(
              enabled: !done,
              onChanged: (x) => answer = x,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'اكتب بـ${widget.presentation.targetLanguageName}',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!done)
              FilledButton(onPressed: submit, child: const Text('تحقق'))
            else
              Card(
                child: ListTile(
                  leading: Icon(correct ? Icons.check_circle : Icons.close),
                  title: Text(correct ? 'أحسنت' : 'نحتاج دليلًا إضافيًا'),
                  subtitle: Text('الإجابة: $expected'),
                ),
              ),
            if (done)
              FilledButton(
                onPressed: () {
                  if (step + 1 >= labels.length) {
                    widget.onDone();
                    Navigator.pop(c);
                  } else {
                    setState(() {
                      step++;
                      done = false;
                      answer = '';
                      start = DateTime.now();
                    });
                  }
                },
                child: Text(step + 1 >= labels.length ? 'إنهاء' : 'التالي'),
              ),
          ],
        ),
      );
}
