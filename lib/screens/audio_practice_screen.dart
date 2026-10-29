import '../services/audio_feedback_engine.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/hybrid_audio_service.dart';
import '../services/tts_service.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

class AudioPracticeScreen extends StatefulWidget {
  final String languageCode;
  const AudioPracticeScreen({super.key, this.languageCode = 'de'});

  @override
  State<AudioPracticeScreen> createState() => _AudioPracticeScreenState();
}

class _AudioPracticeScreenState extends State<AudioPracticeScreen> {
  late final TtsService _tts = TtsService(onStatus: _onTtsStatus);
  late final HybridAudioService _audio = HybridAudioService(ttsService: _tts);
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _isLoading = true;

  String _germanText = '';
  String _arabicText = '';

  @override
  void initState() {
    super.initState();
    _loadRandomSentence();
  }

  void _onTtsStatus(TtsStatus status, {String? locale, String? message}) {
    if (!mounted) return;
    if (status == TtsStatus.completed ||
        status == TtsStatus.stopped ||
        status == TtsStatus.error ||
        status == TtsStatus.unavailable ||
        status == TtsStatus.voiceMissing) {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _loadRandomSentence() async {
    setState(() => _isLoading = true);
    try {
      final db =
          await DatabaseService.instance.getContentDb(widget.languageCode);
      // سحب جملة عشوائية من قاعدة البيانات للتدرب عليها
      final result = await db.query(
        'examples',
        columns: ['sentence', 'translation_ar'],
        where: 'language_code = ?',
        whereArgs: [widget.languageCode],
        orderBy: 'RANDOM()',
        limit: 1,
      );

      if (result.isNotEmpty) {
        _germanText = result.first['sentence']?.toString() ?? '';
        _arabicText = result.first['translation_ar']?.toString() ?? '';
      } else {
        _germanText = widget.languageCode == 'de' ? 'Ich lerne Deutsch.' : '';
        _arabicText = widget.languageCode == 'de'
            ? 'أنا أتعلم الألمانية.'
            : 'لا توجد جملة متاحة.';
      }
    } catch (e) {
      _germanText = '';
      _arabicText = 'خطأ في التحميل.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    if (_germanText.trim().isEmpty || _isPlaying) return;
    setState(() => _isPlaying = true);
    try {
      await _tts
          .configure(speechRate: _playbackSpeed)
          .timeout(const Duration(seconds: 5));
      final played = await _audio.play(
        text: _germanText,
        languageCode: widget.languageCode,
        context: mounted ? context : null,
      );
      if (!played && mounted) setState(() => _isPlaying = false);
    } catch (_) {
      if (mounted) {
        setState(() => _isPlaying = false);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
          content:
              Text(HybridAudioService.fallbackMessage(widget.languageCode)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _stop() async {
    await _audio.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  void _toggleSpeed() {
    setState(() {
      _playbackSpeed = _playbackSpeed == 1.0
          ? AudioFeedbackEngine.getRecommendedSpeed(isSlowMode: true)
          : AudioFeedbackEngine.getRecommendedSpeed(isSlowMode: false);
    });
    if (_isPlaying) unawaited(_stop()); // apply on next playback
  }

  @override
  void dispose() {
    unawaited(_audio.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستماع والنطق'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              children: <Widget>[
                const Spacer(),
                if (_isLoading)
                  const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF38BDF8)))
                else
                  AppBaseGlassCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: <Widget>[
                        const Icon(Icons.graphic_eq_rounded,
                            size: 72, color: Color(0xFF38BDF8)),
                        const SizedBox(height: 18),
                        Text(
                          _germanText,
                          style: AppTypography.display
                              .copyWith(color: Colors.white, fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _arabicText,
                          style: AppTypography.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.8)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              iconSize: 54,
                              icon: Icon(_isPlaying
                                  ? Icons.stop_circle_rounded
                                  : Icons.play_circle_fill_rounded),
                              color: const Color(0xFFF39C6B),
                              onPressed: _isPlaying ? _stop : _speak,
                            ),
                            const SizedBox(width: 16),
                            ActionChip(
                              label: Text('${_playbackSpeed}x',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              onPressed: _toggleSpeed,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded,
                                  color: Colors.white),
                              onPressed: _loadRandomSentence,
                              tooltip: 'جملة جديدة',
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
