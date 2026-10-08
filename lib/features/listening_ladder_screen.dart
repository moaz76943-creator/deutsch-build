import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class ListeningLadderItem {
  final String targetPhrase;
  final String sourceTranslation;
  final String languageCode;

  const ListeningLadderItem({
    required this.targetPhrase,
    required this.sourceTranslation,
    this.languageCode = 'de-DE',
  });
}

class ListeningLadderScreen extends StatefulWidget {
  final ListeningLadderItem item;
  const ListeningLadderScreen({
    super.key,
    this.item = const ListeningLadderItem(
      targetPhrase: 'Guten Tag, wie kann ich Ihnen helfen?',
      sourceTranslation: 'طاب يومك، كيف يمكنني مساعدتك؟',
      languageCode: 'de-DE',
    ),
  });

  @override
  State<ListeningLadderScreen> createState() => _ListeningLadderScreenState();
}

class _ListeningLadderScreenState extends State<ListeningLadderScreen> {
  final FlutterTts _tts = FlutterTts();
  double _speechRate = 0.45;
  int _currentStep = 1; // 1: Target+Source, 2: Target Only, 3: Blind Listen
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(widget.item.languageCode);
    await _tts.setSpeechRate(_speechRate);
  }

  Future<void> _playAudio({double? overrideRate}) async {
    if (overrideRate != null) {
      await _tts.setSpeechRate(overrideRate);
    } else {
      await _tts.setSpeechRate(_speechRate);
    }
    await _tts.speak(widget.item.targetPhrase);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سلّم الاستماع', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('المرحلة $_currentStep من 3', style: AppStyles.subtitle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  children: [
                    IconButton.filledTonal(
                      iconSize: 48,
                      icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                      onPressed: () => _playAudio(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ActionChip(
                          label: const Text('بطيء 0.35x'),
                          onPressed: () => _playAudio(overrideRate: 0.30),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('طبيعي 0.50x'),
                          onPressed: () => _playAudio(overrideRate: 0.48),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_currentStep < 3)
                      AppDirectionalText.target(
                        widget.item.targetPhrase,
                        style: AppStyles.title.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    if (_currentStep == 1 || _showTranslation) ...[
                      const SizedBox(height: 12),
                      AppDirectionalText.arabic(
                        widget.item.sourceTranslation,
                        style: AppStyles.subtitle.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (_currentStep == 3 && !_showTranslation)
                OutlinedButton(
                  onPressed: () => setState(() => _showTranslation = true),
                  child: const Text('إظهار الترجمة للتأكد'),
                ),
              const SizedBox(height: 12),
              AppButton(
                text: _currentStep < 3 ? 'المستوى التالي' : 'إنهاء التدريب',
                onPressed: () {
                  if (_currentStep < 3) {
                    setState(() {
                      _currentStep++;
                      _showTranslation = false;
                    });
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
