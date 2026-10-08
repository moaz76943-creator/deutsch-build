import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class LocalPronunciationTrainerScreen extends StatefulWidget {
  const LocalPronunciationTrainerScreen({super.key});

  @override
  State<LocalPronunciationTrainerScreen> createState() => _LocalPronunciationTrainerScreenState();
}

class _LocalPronunciationTrainerScreenState extends State<LocalPronunciationTrainerScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentIndex = 0;
  bool _isPracticing = false;

  final List<Map<String, String>> _phrases = const [
    {
      'de': 'Entschuldigung, darf ich etwas fragen?',
      'ar': 'معذرة، هل يمكنني أن أسأل شيئاً؟',
      'phonetic': 'إنت-شول-دي-غونغ، دارف إيش إتفاس فراغن؟'
    },
    {
      'de': 'Das ist wirklich sehr interessant.',
      'ar': 'هذا حقاً مثير جداً للاهتمام.',
      'phonetic': 'داس إيست فيرك-ليش زير إنتر-يسانت.'
    },
    {
      'de': 'Ich möchte einen Termin vereinbaren.',
      'ar': 'أود تحديد موعد.',
      'phonetic': 'إيش مش-ته آينن تيرمين فير-آين-بارن.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(0.38); // سرعة نطق مناسبة للترديد والتدريب
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _speakCurrent() {
    _tts.speak(_phrases[_currentIndex]['de']!);
  }

  @override
  Widget build(BuildContext context) {
    final item = _phrases[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تدريب النطق والترديد', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'العبارة ${_currentIndex + 1} من ${_phrases.length}',
                textAlign: TextAlign.center,
                style: AppStyles.subtitle,
              ),
              const SizedBox(height: 24),
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppDirectionalText.target(
                      item['de']!,
                      style: AppStyles.title.copyWith(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['phonetic']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 28),
                    AppDirectionalText.arabic(
                      item['ar']!,
                      style: AppStyles.subtitle.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    IconButton.filledTonal(
                      iconSize: 36,
                      icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                      onPressed: _speakCurrent,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppCard(
                child: Row(
                  children: [
                    Icon(
                      _isPracticing ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isPracticing ? AppColors.error : AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isPracticing
                          ? 'استمع وردد بصوت مسموع...'
                          : 'استمع للنطق البطيء وردد العبارة بصوتك.',
                        style: AppStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: _currentIndex < _phrases.length - 1 ? 'العبارة التالية' : 'إنهاء التدريب',
                icon: Icons.navigate_next_rounded,
                onPressed: () {
                  if (_currentIndex < _phrases.length - 1) {
                    setState(() {
                      _currentIndex++;
                      _isPracticing = false;
                    });
                    _speakCurrent();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
