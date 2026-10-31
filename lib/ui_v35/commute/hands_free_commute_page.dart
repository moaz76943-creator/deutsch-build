import 'package:flutter/material.dart';

import '../../features/commute/domain/commute_models.dart';
import '../../features/commute/hands_free_commute_service.dart';
import '../../models/content.dart';
import '../../services/app_dependencies.dart';
import '../../services/repository.dart';
import 'commute_controls.dart';

class HandsFreeCommutePage extends StatefulWidget {
  const HandsFreeCommutePage({
    super.key,
    required this.repo,
    required this.dependencies,
    required this.onDone,
  });

  final LearnerRepository repo;
  final AppDependencies<ContentItem> dependencies;
  final VoidCallback onDone;

  @override
  State<HandsFreeCommutePage> createState() => _HandsFreeCommutePageState();
}

class _HandsFreeCommutePageState extends State<HandsFreeCommutePage> {
  late final HandsFreeCommuteService<ContentItem> _service;
  List<CommuteReviewItem<ContentItem>> _queue =
      const <CommuteReviewItem<ContentItem>>[];

  bool _playing = false;
  bool _busy = false;
  int _reviewStartedMs = 0;
  String _status =
      'اضغط تشغيل: ألماني → وقفة → المعنى بالعربية → المثال بالألمانية.';

  CommuteReviewItem<ContentItem>? get _current =>
      _queue.isEmpty ? null : _queue.first;

  @override
  void initState() {
    super.initState();
    _service = HandsFreeCommuteService<ContentItem>(
      repository: widget.repo,
      targetAudioRuntime: widget.dependencies.audioRuntime,
      sourceAudioRuntime: widget.dependencies.sourceAudioRuntime,
      targetLanguageCode: widget.dependencies.languagePack.languageCode,
      sourceLanguageCode: widget.dependencies.languagePack.sourceLocale,
      corpus: widget.dependencies.corpus,
    );
    _reloadQueue();
  }

  void _reloadQueue() {
    _queue = _service.pendingQueue(state: widget.repo.load(), limit: 50);
    _reviewStartedMs = DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> _play() async {
    final current = _current;
    if (current == null || _playing || _busy) return;
    setState(() {
      _playing = true;
      _status = 'التسلسل الصوتي يعمل الآن. يمكنك الإيقاف المؤقت في أي وقت.';
    });

    final report = await _service.play(current);
    if (!mounted) return;
    setState(() {
      _playing = false;
      if (report.completed) {
        _status = 'اكتمل التسلسل. اختر أعرفها أو لا أعرفها.';
      } else if (report.stage == CommutePlaybackStage.cancelled) {
        _status = 'تم الإيقاف المؤقت. التشغيل التالي يبدأ العنصر من أوله.';
      } else {
        _status = 'تعذر الصوت عند ${_stageLabel(report.stage)}: '
            '${report.reason ?? 'audio_runtime_unavailable'}.';
      }
    });
  }

  Future<void> _pause() async {
    if (!_playing) return;
    await _service.pause();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _status = 'تم الإيقاف المؤقت. التشغيل التالي يبدأ العنصر من أوله.';
    });
  }

  Future<void> _grade(bool known) async {
    final current = _current;
    if (current == null || _busy) return;
    setState(() => _busy = true);
    if (_playing) {
      await _service.pause();
    }
    final elapsed = DateTime.now().millisecondsSinceEpoch - _reviewStartedMs;
    await _service.recordReview(
      current,
      known: known,
      seconds: (elapsed ~/ 1000).clamp(1, 3600).toInt(),
    );
    if (!mounted) return;

    setState(() {
      _playing = false;
      _busy = false;
      _reloadQueue();
      _status = known
          ? 'سُجلت كمعلومة معروفة في SRS.'
          : 'سُجلت للمراجعة الإضافية في SRS.';
    });
    widget.onDone();

    if (_queue.isNotEmpty) {
      await _play();
    }
  }

  String _stageLabel(CommutePlaybackStage stage) => switch (stage) {
        CommutePlaybackStage.targetTerm => 'الكلمة الألمانية',
        CommutePlaybackStage.sourceMeaning => 'المعنى العربي',
        CommutePlaybackStage.targetExample => 'المثال الألماني',
        CommutePlaybackStage.completed => 'الاكتمال',
        CommutePlaybackStage.cancelled => 'الإيقاف',
      };

  @override
  void dispose() {
    _service.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('وضع التنقل'),
      ),
      body: current == null
          ? const CommuteEmptyState()
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  const Text(
                    'Audio-first SRS • لا تحتاج للنظر إلى الشاشة أثناء التشغيل.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CommuteNowPlayingCard(
                    review: current,
                    targetLanguageCode:
                        widget.dependencies.languagePack.languageCode,
                    sourceLanguageCode:
                        widget.dependencies.languagePack.sourceLocale,
                    position: 1,
                    total: _queue.length,
                    status: _status,
                  ),
                  const SizedBox(height: 16),
                  CommutePlaybackControls(
                    playing: _playing,
                    busy: _busy,
                    onPlay: _play,
                    onPause: _pause,
                    onKnown: () => _grade(true),
                    onUnknown: () => _grade(false),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'إذا لم يكن الصوت المحلي متاحًا، يتوقف التسلسل ويعرض السبب '
                    'بدل تخطي المقطع أو استخدام خدمة سحابية بديلة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
    );
  }
}
