import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../ui/app_design_system.dart';
import 'unified_learning_session.dart';

class WordData {
  final String targetWord;
  final String sourceTranslation;
  final String grammaticalMarker; // أداة، جنس، أو تصنيف حسب اللغة
  final String additionalForms;   // جمع، تصريف، أو صيغ إضافية
  final String exampleTarget;
  final String exampleSource;
  final String linguisticNote;
  final String languageCode;      // مثال: 'de-DE', 'en-US', 'fr-FR', 'es-ES'

  const WordData({
    required this.targetWord,
    required this.sourceTranslation,
    this.grammaticalMarker = '',
    this.additionalForms = '',
    required this.exampleTarget,
    required this.exampleSource,
    this.linguisticNote = '',
    this.languageCode = 'de-DE',
  });
}

class WordProfileScreen extends StatefulWidget {
  final WordData word;
  const WordProfileScreen({super.key, required this.word});

  @override
  State<WordProfileScreen> createState() => _WordProfileScreenState();
}

class _WordProfileScreenState extends State<WordProfileScreen> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage(widget.word.languageCode);
    _tts.setSpeechRate(0.45);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.word.grammaticalMarker.isNotEmpty)
                          Text('${widget.word.grammaticalMarker} ', 
                              style: AppStyles.title.copyWith(color: AppColors.secondary, fontSize: 32)),
                        Text(widget.word.targetWord, style: AppStyles.title.copyWith(fontSize: 32)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.word.sourceTranslation, style: AppStyles.subtitle.copyWith(fontSize: 20)),
                    const SizedBox(height: 16),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.volume_up_rounded, size: 32),
                      onPressed: () => _tts.speak('${widget.word.grammaticalMarker} ${widget.word.targetWord}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.word.additionalForms.isNotEmpty) ...[
                      _buildDetailRow('الصيغ الإضافية:', widget.word.additionalForms),
                      const Divider(height: 24),
                    ],
                    const Text('مثال في جملة:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(widget.word.exampleTarget, style: AppStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16))),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary),
                          onPressed: () => _tts.speak(widget.word.exampleTarget),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.word.exampleSource, style: AppStyles.subtitle),
                    if (widget.word.linguisticNote.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildDetailRow('ملاحظة لغوية:', widget.word.linguisticNote, valueColor: AppColors.warning),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'تدرّب على هذه المفردة',
                icon: Icons.fitness_center_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UnifiedLearningSession(
                        tasks: [
                          LearningTask(
                            id: widget.word.targetWord,
                            prompt: 'اكتب الكلمة المقابلة لـ: ${widget.word.sourceTranslation}',
                            correctAnswer: widget.word.targetWord,
                            explanation: widget.word.linguisticNote.isNotEmpty 
                                ? widget.word.linguisticNote 
                                : 'تذكر التهجئة الصحيحة والعلامات الملحقة.',
                            grammarPattern: 'Vocabulary Recall',
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: AppStyles.body.copyWith(color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
