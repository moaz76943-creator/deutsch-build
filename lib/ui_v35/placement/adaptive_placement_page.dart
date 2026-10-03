import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../features/audio/domain/entities/audio_request.dart';
import '../../features/audio/domain/services/i_audio_runtime.dart';
import '../../language/language_content_quality.dart';
import '../../language/language_exercise_strategy.dart';
import '../../language/language_presentation.dart';
import '../../models/assessment.dart';
import '../../models/content.dart';
import '../../models/diagnostic_placement.dart';
import '../../models/learner.dart';
import '../../services/adaptive_placement_engine.dart';
import '../../services/adaptive_placement_service.dart';
import '../../services/repository.dart';
import '../shared/text/bidi_text.dart';
import 'placement_result_panel.dart';

class AdaptivePlacementPage extends StatefulWidget {
  const AdaptivePlacementPage({
    super.key,
    required this.repo,
    required this.corpus,
    required this.exerciseStrategy,
    required this.contentQuality,
    required this.placementPresentation,
    required this.targetLanguageName,
    required this.languageCode,
    required this.sourceLanguageCode,
    required this.audioRuntime,
    required this.onDone,
  });

  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguageContentQuality contentQuality;
  final PlacementPresentation placementPresentation;
  final String targetLanguageName;
  final String languageCode;
  final String sourceLanguageCode;
  final IAudioRuntime audioRuntime;
  final VoidCallback onDone;

  @override
  State<AdaptivePlacementPage> createState() => _AdaptivePlacementPageState();
}

class _AdaptivePlacementPageState extends State<AdaptivePlacementPage> {
  final TextEditingController _answer = TextEditingController();
  final List<DiagnosticResponse> _responses = <DiagnosticResponse>[];
  late LearnerState _baseline;
  late int _seed;
  DiagnosticQuestion? _current;
  PlacementDiagnosticResult? _result;
  bool _submitted = false;
  bool _correct = false;
  bool _saving = false;
  bool _listeningUnavailable = false;

  @override
  void initState() {
    super.initState();
    _baseline = widget.repo.load();
    final now = DateTime.now();
    _seed = now.year * 10000 + now.month * 100 + now.day;
    _current = _nextQuestion();
  }

  DiagnosticQuestion? _nextQuestion() => AdaptivePlacementEngine.nextQuestion(
        items: widget.corpus,
        state: _baseline,
        responses: _responses,
        exerciseStrategy: widget.exerciseStrategy,
        isLearnable: widget.contentQuality.isLearnable,
        seed: _seed,
      );

  Future<void> _submit() async {
    final current = _current;
    if (current == null || _submitted || _saving) return;
    final answer = _answer.text;
    final q = current.question;
    _correct = assessmentAnswerMatches(
      AssessmentResponse(
        questionId: q.id,
        itemId: q.itemId,
        answer: answer,
        correct: true,
        hinted: false,
      ),
      q,
    );
    _responses.add(
      DiagnosticResponse(
        questionId: q.id,
        itemId: q.itemId,
        dimension: current.dimension,
        correct: _correct,
        hinted: false,
        skipped: false,
        difficultyBand: current.difficultyBand,
      ),
    );
    if (mounted) setState(() => _submitted = true);
  }

  Future<void> _playListening() async {
    final current = _current;
    if (current == null || current.dimension != DiagnosticDimension.listening) {
      return;
    }
    final result = await widget.audioRuntime.play(
      AudioRequest(
        text: current.question.expected,
        languageCode: widget.languageCode,
        conceptId: current.question.itemId,
        variant: AudioVariant.sentence,
      ),
    );
    if (!mounted) return;
    setState(() => _listeningUnavailable = !result.played);
  }

  Future<void> _skipUnavailableListening() async {
    final current = _current;
    if (current == null ||
        current.dimension != DiagnosticDimension.listening ||
        !_listeningUnavailable ||
        _saving) {
      return;
    }
    _responses.add(
      DiagnosticResponse(
        questionId: current.question.id,
        itemId: current.question.itemId,
        dimension: current.dimension,
        correct: false,
        hinted: false,
        skipped: true,
        difficultyBand: current.difficultyBand,
      ),
    );
    await _advance();
  }

  Future<void> _advance() async {
    if (_saving) return;
    final next = _nextQuestion();
    if (next == null) {
      await _finish();
      return;
    }
    setState(() {
      _current = next;
      _submitted = false;
      _correct = false;
      _listeningUnavailable = false;
      _answer.clear();
    });
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final result = AdaptivePlacementEngine.score(_responses);
      await AdaptivePlacementService(widget.repo).recordResult(result);
      widget.onDone();
      if (!mounted) return;
      setState(() {
        _result = result;
        _current = null;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.placementPresentation.resultTitle)),
        body: PlacementResultPanel(
          result: result,
          onClose: () => Navigator.maybePop(context),
        ),
      );
    }

    final current = _current;
    if (current == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.placementPresentation.title)),
        body: const Center(
          child: Text('لا توجد عينة محتوى صالحة للتشخيص حاليًا.'),
        ),
      );
    }

    final question = current.question;
    final progress =
        (_responses.length + 1) / AdaptivePlacementEngine.defaultMaxQuestions;

    return Scaffold(
      appBar: AppBar(title: Text(widget.placementPresentation.title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0).toDouble()),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(label: Text(_dimensionLabel(current.dimension))),
              const Spacer(),
              Text('السؤال ${_responses.length + 1}'),
            ],
          ),
          const SizedBox(height: 16),
          BidiText(
            DirectionalText.forLanguage(
              question.prompt,
              languageCode: widget.sourceLanguageCode,
              semanticRole: LinguisticSemanticRole.explanation,
            ),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (current.dimension == DiagnosticDimension.listening) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _playListening,
              icon: const Icon(Icons.volume_up_outlined),
              label: const Text('تشغيل الصوت المحلي'),
            ),
            if (_listeningUnavailable) ...[
              const SizedBox(height: 8),
              const Text(
                'الصوت الألماني المحلي غير متاح؛ لن يُحتسب هذا السؤال.',
              ),
              TextButton(
                onPressed: _skipUnavailableListening,
                child: const Text('تجاوز دون احتساب'),
              ),
            ],
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _answer,
            enabled: !_submitted && !_saving,
            textDirection: TextDirection.ltr,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText:
                  '${widget.placementPresentation.answerLabel} بـ${widget.targetLanguageName}',
            ),
          ),
          const SizedBox(height: 12),
          if (!_submitted)
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: const Text('تحقق'),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _correct ? '✓ صحيح' : '✗ يحتاج مراجعة',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text('الإجابة المستهدفة:'),
                    const SizedBox(height: 4),
                    BidiText(
                      DirectionalText.forLanguage(
                        question.expected,
                        languageCode: widget.languageCode,
                        semanticRole: LinguisticSemanticRole.example,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _saving ? null : _advance,
              child: Text(
                AdaptivePlacementEngine.shouldStop(_responses)
                    ? widget.placementPresentation.finishLabel
                    : widget.placementPresentation.nextLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  static String _dimensionLabel(DiagnosticDimension dimension) =>
      switch (dimension) {
        DiagnosticDimension.meaning => 'المعنى',
        DiagnosticDimension.grammar => 'القواعد',
        DiagnosticDimension.listening => 'الاستماع',
        DiagnosticDimension.transfer => 'النقل',
        DiagnosticDimension.production => 'الإنتاج',
      };
}
