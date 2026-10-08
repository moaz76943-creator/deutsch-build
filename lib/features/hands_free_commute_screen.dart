import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class CommuteCard {
  final String target;
  final String source;
  const CommuteCard(this.target, this.source);
}

class HandsFreeCommuteScreen extends StatefulWidget {
  const HandsFreeCommuteScreen({super.key});

  @override
  State<HandsFreeCommuteScreen> createState() => _HandsFreeCommuteScreenState();
}

class _HandsFreeCommuteScreenState extends State<HandsFreeCommuteScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  int _currentIndex = 0;
  Timer? _loopTimer;

  final List<CommuteCard> _items = const [
    CommuteCard('Ich brauche Hilfe.', 'أنا بحاجة إلى مساعدة.'),
    CommuteCard('Wo ist der Bahnhof?', 'أين محطة القطار؟'),
    CommuteCard('Wie viel kostet das?', 'كم سعر هذا؟'),
    CommuteCard('Ich verstehe nur ein bisschen Deutsch.', 'أنا أفهم القليل من الألمانية فقط.'),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.42);
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startAudioCycle();
    } else {
      _loopTimer?.cancel();
      _tts.stop();
    }
  }

  void _startAudioCycle() {
    if (!_isPlaying) return;
    final item = _items[_currentIndex];
    
    // نطق الجملة الألمانية
    _tts.speak(item.target);

    // مهلة زمنية للاستماع والتفكير ثم الانتقال التلقائي
    _loopTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _items.length;
      });
      _startAudioCycle();
    });
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      appBar: AppBar(
        title: const Text('وضع الاستماع التلقائي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.headphones_rounded, size: 72, color: AppColors.secondary),
              const SizedBox(height: 12),
              const Text(
                'مناسب للاسترخاء، أوقات الانشغال، أو قبل النوم دون لمس الشاشة',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 28),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    AppDirectionalText.target(
                      item.target,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppDirectionalText.arabic(
                      item.source,
                      style: AppStyles.subtitle.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              IconButton.filled(
                iconSize: 56,
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                onPressed: _togglePlay,
              ),
              const SizedBox(height: 16),
              Text(
                _isPlaying ? 'التشغيل التلقائي نشط...' : 'اضغط للبدء والاستماع الذاتي المستمر',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
