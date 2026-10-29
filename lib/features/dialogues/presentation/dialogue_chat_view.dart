import 'package:flutter/material.dart';

import '../../../design_system/app_audio_button.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../domain/dialogue_engine.dart';
import '../domain/dialogue_models.dart';

class DialogueChatView extends StatefulWidget {
  const DialogueChatView({
    required this.scenario,
    required this.repository,
    required this.audioPort,
    this.onCompleted,
    super.key,
  });

  final DialogueScenario scenario;
  final DialogueRepository repository;
  final DialogueAudioPort audioPort;
  final ValueChanged<DialogueSessionResult>? onCompleted;

  @override
  State<DialogueChatView> createState() => _DialogueChatViewState();
}

class _DialogueChatViewState extends State<DialogueChatView> {
  late final DialogueEngine _engine;
  final Set<String> _revealedTranslations = <String>{};
  final Set<String> _busyAudioIds = <String>{};

  @override
  void initState() {
    super.initState();
    _engine = DialogueEngine(widget.scenario);
  }

  void _toggleTranslation(DialogueTurn turn) {
    setState(() {
      if (!_revealedTranslations.add(turn.id)) {
        _revealedTranslations.remove(turn.id);
      }
    });
  }

  Future<void> _speakTurn(DialogueTurn turn) async {
    await _speakWithId(turn.id, turn);
  }

  Future<void> _speakChoice(DialogueChoice choice) async {
    final audioId = 'choice:${choice.id}';
    await _speakWithId(
      audioId,
      DialogueTurn(
        id: audioId,
        speaker: DialogueSpeaker.learner,
        germanText: choice.germanText,
        arabicTranslation: choice.arabicTranslation,
        audioConceptId: choice.id,
      ),
    );
  }

  Future<void> _speakWithId(
    String audioId,
    DialogueTurn turn,
  ) async {
    if (_busyAudioIds.contains(audioId)) return;
    setState(() => _busyAudioIds.add(audioId));
    try {
      await widget.audioPort.speak(turn);
    } finally {
      if (mounted) {
        setState(() => _busyAudioIds.remove(audioId));
      }
    }
  }

  void _choose(DialogueChoice choice) {
    final step = _engine.choose(choice.id);
    if (step.completed) {
      final result = _engine.result;
      widget.repository.recordCompletion(result);
      widget.onCompleted?.call(result);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _engine.currentNode;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              theme.colorScheme.surface,
              AppColors.primary.withAlpha(18),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(
                titleArabic: widget.scenario.titleArabic,
                titleGerman: widget.scenario.titleGerman,
                scorePercent: _engine.scorePercent,
              ),
              Expanded(
                child: ListView.builder(
                  key: const Key('dialogue-transcript'),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: _engine.transcript.length,
                  itemBuilder: (context, index) {
                    final turn = _engine.transcript[index];
                    return _DialogueBubble(
                      turn: turn,
                      translationVisible:
                          _revealedTranslations.contains(turn.id),
                      audioBusy: _busyAudioIds.contains(turn.id),
                      onToggleTranslation: () =>
                          _toggleTranslation(turn),
                      onListen: () => _speakTurn(turn),
                    );
                  },
                ),
              ),
              if (_engine.isCompleted)
                _CompletionPanel(result: _engine.result)
              else
                _ChoicePanel(
                  node: current,
                  busyAudioIds: _busyAudioIds,
                  onChoose: _choose,
                  onListen: _speakChoice,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.titleArabic,
    required this.titleGerman,
    required this.scorePercent,
  });

  final String titleArabic;
  final String titleGerman;
  final int scorePercent;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: AppGlassCard(
          glowColor: AppColors.primary,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      titleArabic,
                      languageCode: 'ar',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 2),
                    AppDirectionalText(
                      titleGerman,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
              AppDirectionalText(
                '$scorePercent%',
                languageCode: 'ar',
                style: AppTypography.title.copyWith(
                  color: AppColors.mastery,
                ),
              ),
            ],
          ),
        ),
      );
}

class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({
    required this.turn,
    required this.translationVisible,
    required this.audioBusy,
    required this.onToggleTranslation,
    required this.onListen,
  });

  final DialogueTurn turn;
  final bool translationVisible;
  final bool audioBusy;
  final VoidCallback onToggleTranslation;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final learner = turn.speaker == DialogueSpeaker.learner;
    final accent = learner ? AppColors.secondary : AppColors.primary;
    return Align(
      alignment: learner ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AppGlassCard(
            key: ValueKey<String>('dialogue-turn-${turn.id}'),
            onTap: onToggleTranslation,
            borderColor: accent.withAlpha(95),
            glowColor: accent,
            opacity: learner ? .15 : .10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        turn.germanText,
                        languageCode: 'de',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (translationVisible) ...<Widget>[
                        const SizedBox(height: 8),
                        AppDirectionalText(
                          turn.arabicTranslation,
                          key: ValueKey<String>(
                            'dialogue-translation-${turn.id}',
                          ),
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AppAudioButton(
                  key: ValueKey<String>('dialogue-listen-${turn.id}'),
                  onPressed: audioBusy ? null : onListen,
                  semanticLabel: 'استمع إلى الجملة الألمانية',
                  isBusy: audioBusy,
                  activeColor: accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.node,
    required this.busyAudioIds,
    required this.onChoose,
    required this.onListen,
  });

  final DialogueNode node;
  final Set<String> busyAudioIds;
  final ValueChanged<DialogueChoice> onChoose;
  final ValueChanged<DialogueChoice> onListen;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'اختر الرد المناسب',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            for (final choice in node.choices)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppGlassCard(
                  key: ValueKey<String>('dialogue-choice-${choice.id}'),
                  onTap: () => onChoose(choice),
                  borderColor: AppColors.secondary.withAlpha(88),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AppDirectionalText(
                              choice.germanText,
                              languageCode: 'de',
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AppDirectionalText(
                              choice.arabicTranslation,
                              languageCode: 'ar',
                              style: AppTypography.label,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppAudioButton(
                        onPressed:
                            busyAudioIds.contains('choice:${choice.id}')
                                ? null
                                : () => onListen(choice),
                        semanticLabel: 'استمع إلى الرد الألماني',
                        isBusy:
                            busyAudioIds.contains('choice:${choice.id}'),
                        activeColor: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

class _CompletionPanel extends StatelessWidget {
  const _CompletionPanel({required this.result});

  final DialogueSessionResult result;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: AppGlassCard(
          glowColor: AppColors.mastery,
          borderColor: AppColors.mastery.withAlpha(100),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.mastery,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppDirectionalText(
                  'أكملت الحوار بنجاح — النتيجة '
                  '${result.scorePercent}%',
                  languageCode: 'ar',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
