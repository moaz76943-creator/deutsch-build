import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioStudyPlayer extends StatefulWidget {
  final List<Map<String, String>> words;

  const AudioStudyPlayer({
    super.key,
    required this.words,
  });

  @override
  State<AudioStudyPlayer> createState() => _AudioStudyPlayerState();
}

class _AudioStudyPlayerState extends State<AudioStudyPlayer> {
  final FlutterTts _tts = FlutterTts();
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _showTranslation = false;
  Timer? _loopTimer;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _startLoop() {
    if (widget.words.isEmpty) return;
    setState(() => _isPlaying = true);
    _playCurrentStep();
  }

  void _pauseLoop() {
    _loopTimer?.cancel();
    _tts.stop();
    setState(() => _isPlaying = false);
  }

  Future<void> _playCurrentStep() async {
    if (!_isPlaying || !mounted) return;

    final word = widget.words[_currentIndex];
    setState(() => _showTranslation = false);

    // نطق الكلمة الألمانية
    await _tts.speak(word['german'] ?? '');

    // إظهار الترجمة بعد فاصل زمني قصير
    _loopTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted || !_isPlaying) return;
      setState(() => _showTranslation = true);

      // الانتقال للكلمة التالية تلقائياً بعد مهلة استيعاب
      _loopTimer = Timer(const Duration(milliseconds: 2200), () {
        if (!mounted || !_isPlaying) return;
        if (_currentIndex < widget.words.length - 1) {
          setState(() => _currentIndex++);
          _playCurrentStep();
        } else {
          setState(() {
            _isPlaying = false;
            _currentIndex = 0;
          });
        }
      });
    });
  }

  void _nextWord() {
    _pauseLoop();
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _showTranslation = false;
      });
    }
  }

  void _prevWord() {
    _pauseLoop();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showTranslation = false;
      });
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return const Center(child: Text('لا توجد كلمات متاحة حالياً'));
    }

    final current = widget.words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المشغل الصوتي التلقائي'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الكلمة ${_currentIndex + 1} من ${widget.words.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              // بطاقة الكلمة الألمانية
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        current['german'] ?? '',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showTranslation ? 1.0 : 0.0,
                        child: Text(
                          current['arabic'] ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // أزرار التحكم
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: _currentIndex > 0 ? _prevWord : null,
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton.large(
                    onPressed: _isPlaying ? _pauseLoop : _startLoop,
                    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: _currentIndex < widget.words.length - 1 ? _nextWord : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
