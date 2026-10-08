import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class DialogueChoice {
  final String userText;
  final String nextNpcText;
  final String feedback;

  const DialogueChoice({
    required this.userText,
    required this.nextNpcText,
    required this.feedback,
  });
}

class DialogueStep {
  final String npcPrompt;
  final List<DialogueChoice> choices;

  const DialogueStep({
    required this.npcPrompt,
    required this.choices,
  });
}

class BranchingDialoguesScreen extends StatefulWidget {
  const BranchingDialoguesScreen({super.key});

  @override
  State<BranchingDialoguesScreen> createState() => _BranchingDialoguesScreenState();
}

class _BranchingDialoguesScreenState extends State<BranchingDialoguesScreen> {
  final FlutterTts _tts = FlutterTts();
  String _currentNpcText = 'Guten Tag! Wie kann ich Ihnen in der Apotheke helfen?';
  String _lastFeedback = '';
  int _stepIndex = 0;

  final List<DialogueStep> _dialogueFlow = const [
    DialogueStep(
      npcPrompt: 'Guten Tag! Wie kann ich Ihnen in der Apotheke helfen?',
      choices: [
        DialogueChoice(
          userText: 'Ich brauche etwas gegen Kopfschmerzen.',
          nextNpcText: 'Haben Sie ein Rezept vom Arzt oder möchten Sie ein rezeptfreies Medikament?',
          feedback: 'خيار ممتاز! تعبير مباشر ومناسب في الصيدلية.',
        ),
        DialogueChoice(
          userText: 'Haben Sie Hustensaft für mein Kind?',
          nextNpcText: 'Ja, wie alt ist das Kind bitte?',
          feedback: 'صياغة صحيحة ودقيقة لطلب دواء سعال للأطفال.',
        ),
      ],
    ),
    DialogueStep(
      npcPrompt: 'Haben Sie ein Rezept vom Arzt oder möchten Sie ein rezeptfreies Medikament?',
      choices: [
        DialogueChoice(
          userText: 'Ein rezeptfreies Medikament, bitte. Zum Beispiel Ibuprofen.',
          nextNpcText: 'Alles klar, hier ist Ibuprofen 400. Bitte nach dem Essen einnehmen.',
          feedback: 'طلب مكتمل واستجابة واضحة.',
        ),
        DialogueChoice(
          userText: 'Ich habe hier das rote Rezept.',
          nextNpcText: 'Danke schön. Ich hole das Medikament sofort aus dem Lager.',
          feedback: 'ممتاز، الوصفة الحمراء تغطيها التأمينات القانونية في ألمانيا.',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(0.45);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _chooseOption(DialogueChoice choice) {
    setState(() {
      _lastFeedback = choice.feedback;
      _currentNpcText = choice.nextNpcText;
      _stepIndex++;
    });
    _tts.speak(choice.nextNpcText);
  }

  @override
  Widget build(BuildContext context) {
    final hasNext = _stepIndex < _dialogueFlow.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('محادثة تفاعلية واقعية', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الصيدلي (Apotheker):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                          onPressed: () => _tts.speak(_currentNpcText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppDirectionalText.target(
                      _currentNpcText,
                      style: AppStyles.title.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              if (_lastFeedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_lastFeedback, style: AppStyles.body)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (hasNext) ...[
                const Text('اختر ردك المناسب:', style: AppStyles.subtitle),
                const SizedBox(height: 12),
                ..._dialogueFlow[_stepIndex].choices.map((choice) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        onPressed: () => _chooseOption(choice),
                        child: AppDirectionalText.target(
                          choice.userText,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    )),
              ] else ...[
                AppCard(
                  child: Column(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.success, size: 48),
                      const SizedBox(height: 12),
                      const Text('أحسنت! أتممت الموقف الحياتي بنجاح.', style: AppStyles.title),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'إنهاء الحوار',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
