import '../services/audio_feedback_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

class AudioPracticeScreen extends StatefulWidget {
  final String languageCode;
  const AudioPracticeScreen({super.key, this.languageCode = 'de'});

  @override
  State<AudioPracticeScreen> createState() => _AudioPracticeScreenState();
}

class _AudioPracticeScreenState extends State<AudioPracticeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _isLoading = true;
  
  String _germanText = '';
  String _arabicText = '';

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadRandomSentence();
  }

  Future<void> _initTts() async {
    final locale = AudioFeedbackEngine.resolveLocaleTag(widget.languageCode);
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setPitch(AudioFeedbackEngine.getPitchForGender(''));
    await _flutterTts.setSpeechRate(_playbackSpeed);

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _loadRandomSentence() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseService.instance.contentDb;
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
        _germanText = result.first['sentence'] as String;
        _arabicText = result.first['translation_ar'] as String;
      } else {
        _germanText = 'Ich lerne Deutsch.';
        _arabicText = 'أنا أتعلم الألمانية.';
      }
    } catch (e) {
      _germanText = 'Fehler beim Laden.';
      _arabicText = 'خطأ في التحميل.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    if (_germanText.isEmpty) return;
    setState(() => _isPlaying = true);
    await _flutterTts.setSpeechRate(_playbackSpeed);
    await _flutterTts.speak(_germanText);
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  void _toggleSpeed() {
    setState(() {
      _playbackSpeed = _playbackSpeed == 1.0 ? AudioFeedbackEngine.getRecommendedSpeed(isSlowMode: true) : AudioFeedbackEngine.getRecommendedSpeed(isSlowMode: false);
    });
    if (_isPlaying) _speak(); // إعادة التشغيل بالسرعة الجديدة
  }

  @override
  void dispose() {
    _flutterTts.stop();
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
                  const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                else
                  AppBaseGlassCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: <Widget>[
                        const Icon(Icons.graphic_eq_rounded, size: 72, color: Color(0xFF38BDF8)),
                        const SizedBox(height: 18),
                        Text(
                          _germanText,
                          style: AppTypography.display.copyWith(color: Colors.white, fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _arabicText,
                          style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              iconSize: 54,
                              icon: Icon(_isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded),
                              color: const Color(0xFFF39C6B),
                              onPressed: _isPlaying ? _stop : _speak,
                            ),
                            const SizedBox(width: 16),
                            ActionChip(
                              label: Text('${_playbackSpeed}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              onPressed: _toggleSpeed,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
