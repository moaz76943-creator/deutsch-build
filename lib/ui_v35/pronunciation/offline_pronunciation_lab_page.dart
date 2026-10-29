import 'package:flutter/material.dart';

import '../../features/audio/domain/entities/audio_playback_result.dart';
import '../../features/pronunciation/domain/pronunciation_models.dart';
import '../../features/pronunciation/pronunciation_lab_service.dart';
import '../../language/german/german_pronunciation_catalog.dart';
import '../../models/content.dart';
import '../../services/app_dependencies.dart';
import '../../services/repository.dart';
import 'pronunciation_lab_sections.dart';

class OfflinePronunciationLabPage extends StatefulWidget {
  const OfflinePronunciationLabPage({
    super.key,
    required this.repo,
    required this.dependencies,
    required this.onDone,
  });

  final LearnerRepository repo;
  final AppDependencies<ContentItem> dependencies;
  final VoidCallback onDone;

  @override
  State<OfflinePronunciationLabPage> createState() =>
      _OfflinePronunciationLabPageState();
}

class _OfflinePronunciationLabPageState
    extends State<OfflinePronunciationLabPage> {
  late final PronunciationLabService<ContentItem> _service;
  late final List<PronunciationContrast> _contrasts;
  List<PronunciationConfusionStat> _confusions =
      const <PronunciationConfusionStat>[];

  PronunciationTrial<ContentItem>? _trial;
  PronunciationPerceptionResult? _perception;
  PronunciationProductionFeedback? _production;
  String _audioStatus = 'ابدأ بالاستماع ثم اختر الكلمة التي سمعتها.';
  int _round = 0;
  bool _slow = false;
  bool _audioBusy = false;
  bool _productionBusy = false;

  @override
  void initState() {
    super.initState();
    _service = PronunciationLabService<ContentItem>(
      repository: widget.repo,
      audioRuntime: widget.dependencies.audioRuntime,
      signalProbe: widget.dependencies.pronunciationSignalProbe,
      languageCode: widget.dependencies.languagePack.speechProfile.languageCode,
      corpus: widget.dependencies.corpus,
    );
    _contrasts = _service.availableContrasts(
      GermanPronunciationCatalog.contrasts,
    );
    _confusions = _service.confusionStats();
    _prepareTrial();
  }

  void _prepareTrial() {
    if (_contrasts.isEmpty) {
      _trial = null;
      return;
    }
    final contrast = _contrasts[_round % _contrasts.length];
    _trial = _service.buildTrial(contrast, round: _round);
    _perception = null;
    _production = null;
    _audioStatus = 'استمع دون النظر إلى الإجابة، ثم اختر ما سمعت.';
  }

  Future<void> _listen() async {
    final trial = _trial;
    if (trial == null || _audioBusy) return;
    setState(() => _audioBusy = true);
    final result = await _service.playTarget(trial, slow: _slow);
    if (!mounted) return;
    setState(() {
      _audioBusy = false;
      _audioStatus = switch (result.source) {
        AudioPlaybackSource.recorded => 'تم تشغيل التسجيل المحلي.',
        AudioPlaybackSource.offlineTts => 'تم تشغيل صوت TTS ألماني محلي.',
        AudioPlaybackSource.unavailable =>
          'الصوت المحلي غير متاح: ${result.reason ?? 'unknown'}',
      };
    });
  }

  Future<void> _choose(String token) async {
    final trial = _trial;
    if (trial == null || _perception != null) return;
    final result = await _service.answerPerception(
      trial,
      selectedToken: token,
      seconds: 6,
    );
    if (!mounted) return;
    setState(() {
      _perception = result;
      _confusions = _service.confusionStats(widget.repo.load());
    });
    widget.onDone();
  }

  Future<void> _captureProduction() async {
    final trial = _trial;
    if (trial == null || _productionBusy) return;
    setState(() => _productionBusy = true);
    final feedback = await _service.captureProduction(trial);
    if (!mounted) return;
    setState(() {
      _productionBusy = false;
      _production = feedback;
    });
  }

  void _nextRound() {
    setState(() {
      _round++;
      _prepareTrial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trial = _trial;
    return Scaffold(
      appBar: AppBar(title: const Text('مختبر النطق المحلي')),
      body: _contrasts.isEmpty || trial == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'لا توجد أزواج نطق موثوقة متاحة في حزمة المحتوى النشطة.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.offline_bolt_outlined),
                      title: Text('Offline Pronunciation Lab'),
                      subtitle: Text(
                        'اسمع → ميّز → انطق → افحص الإشارة محليًا → أعد المحاولة. '
                        'لا يوجد Cloud STT أو رفع للتسجيل.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PronunciationPerceptionCard(
                    contrast: trial.contrast,
                    options: trial.options,
                    slow: _slow,
                    busy: _audioBusy || _perception != null,
                    onSlowChanged: (value) => setState(() => _slow = value),
                    onListen: _listen,
                    onChoose: _choose,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _audioStatus,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_perception != null) ...[
                    const SizedBox(height: 12),
                    PronunciationFeedbackCard(
                      result: _perception!,
                      coachingAr: trial.contrast.coachingAr,
                    ),
                    const SizedBox(height: 12),
                    PronunciationProductionCard(
                      targetToken: trial.target.token,
                      busy: _productionBusy,
                      feedback: _production,
                      onCapture: _captureProduction,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _nextRound,
                      icon: const Icon(Icons.navigate_next),
                      label: const Text('جولة نطق جديدة'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  PronunciationConfusionPanel(
                    stats: _confusions,
                    catalog: _contrasts,
                  ),
                ],
              ),
            ),
    );
  }
}
