import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/content_contract.dart';
import '../../core/curriculum/advanced_vocabulary.dart';
import '../../core/design/flashcards_3d/flashcard_3d_models.dart';
import '../../design_system/app_audio_button.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart';
import '../../features/phase3_integration/life_feature_runtime.dart';
import 'flip_card_widget.dart';
import 'phase10_presentation_bridge.dart';

abstract final class VocabularyProjectionFactory {
  static VocabularyFlashcardProjection fromContent(LearningContent item) {
    final marker = item.grammaticalMarker.trim();
    final normalizedMarker = marker.toLowerCase();
    final article = const <String>{'der', 'die', 'das', 'plural'}
            .contains(normalizedMarker)
        ? normalizedMarker
        : null;
    final supporting = <String>[
      if (marker.isNotEmpty) marker,
      if (item.pluralForm.trim().isNotEmpty)
        'Plural: ${item.pluralForm.trim()}',
    ].join(' • ');

    return VocabularyFlashcardProjection(
      id: item.id,
      frontText: item.sourceText,
      backText: item.translationText,
      frontLanguageCode: 'de',
      backLanguageCode: 'ar',
      article: article,
      frontSupportingText:
          supporting.isEmpty ? item.exampleText : supporting,
      backSupportingText: item.exampleTranslationText,
      semanticLabel: '${item.topic}: ${item.sourceText}',
    );
  }

  static List<VocabularyFlashcardProjection> fromContentList(
    Iterable<LearningContent> items,
  ) =>
      List<VocabularyFlashcardProjection>.unmodifiable(
        items.map(fromContent),
      );
}

abstract final class VocabularyFlashcard3DAdapter {
  static Flashcard3DData fromProjection(
    VocabularyFlashcardProjection projection,
  ) =>
      Flashcard3DData(
        id: projection.id,
        frontText: projection.frontText,
        backText: projection.backText,
        frontLanguageCode: projection.frontLanguageCode,
        backLanguageCode: projection.backLanguageCode,
        article: projection.article,
        frontSupportingText: projection.frontSupportingText,
        backSupportingText: projection.backSupportingText,
        semanticLabel: projection.semanticLabel,
      );

  static List<Flashcard3DData> deck(
    Iterable<VocabularyFlashcardProjection> projections,
  ) =>
      List<Flashcard3DData>.unmodifiable(
        projections.map(fromProjection),
      );
}

final class Phase3FlashcardDeckPage extends StatefulWidget {
  const Phase3FlashcardDeckPage({
    required this.title,
    required this.emptyText,
    required this.projections,
    this.onAudio,
    this.presentationBridge,
    super.key,
  });

  final String title;
  final String emptyText;
  final List<VocabularyFlashcardProjection> projections;
  final FlashcardAudioCallback? onAudio;
  final Phase10PresentationBridge? presentationBridge;

  @override
  State<Phase3FlashcardDeckPage> createState() =>
      _Phase3FlashcardDeckPageState();
}

final class _Phase3FlashcardDeckPageState
    extends State<Phase3FlashcardDeckPage> {
  late final List<Flashcard3DData> _cards;
  late final Future<Phase10PresentationBridge> _bridgeFuture;
  late final bool _ownsBridge;

  final Set<String> _validatedCards = <String>{};
  final Set<String> _revealedCards = <String>{};
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _cards = VocabularyFlashcard3DAdapter.deck(widget.projections);
    _ownsBridge = widget.presentationBridge == null;
    _bridgeFuture = widget.presentationBridge == null
        ? Phase10PresentationBridge.start()
        : Future<Phase10PresentationBridge>.value(
            widget.presentationBridge,
          );
  }

  @override
  void dispose() {
    if (_ownsBridge) {
      unawaited(
        _bridgeFuture.then((bridge) => bridge.close()).catchError((_) {}),
      );
    }
    super.dispose();
  }

  Flashcard3DData get _activeCard => _cards[_index];

  void _moveBy(int delta) {
    if (_cards.isEmpty) return;
    final next = ((_index + delta) % _cards.length + _cards.length) %
        _cards.length;
    if (next == _index) return;
    setState(() => _index = next);
  }

  void _onFaceChanged(FlipCardFace face) {
    if (face != FlipCardFace.back || _cards.isEmpty) return;
    final card = _activeCard;
    if (!_revealedCards.add(card.id)) return;

    unawaited(
      _bridgeFuture.then((bridge) async {
        final result = await bridge.validateCard(card);
        if (!mounted) return;
        if (result.validated) {
          setState(() => _validatedCards.add(card.id));
          bridge.recordCardInteraction(
            cardId: card.id,
            score: 0.5,
            points: 1,
          );
        }
      }).catchError((_) {}),
    );
  }

  void _onSwipe(FlipCardSwipeDirection direction) {
    if (_cards.isEmpty) return;
    final card = _activeCard;

    final interaction = switch (direction) {
      FlipCardSwipeDirection.right => (score: 1.0, points: 3),
      FlipCardSwipeDirection.left => (score: 0.0, points: 0),
      FlipCardSwipeDirection.up => (score: 0.75, points: 2),
      FlipCardSwipeDirection.down => (score: 0.25, points: 0),
    };

    unawaited(
      _bridgeFuture.then((bridge) async {
        final validation = await bridge.validateCard(card);
        if (!validation.validated) return;
        bridge.recordCardInteraction(
          cardId: card.id,
          score: interaction.score,
          points: interaction.points,
        );
      }).catchError((_) {}),
    );

    switch (direction) {
      case FlipCardSwipeDirection.left:
        _moveBy(1);
        return;
      case FlipCardSwipeDirection.right:
        _moveBy(-1);
        return;
      case FlipCardSwipeDirection.up:
      case FlipCardSwipeDirection.down:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(child: Text(widget.emptyText)),
      );
    }

    final card = _activeCard;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 32)
                .clamp(260.0, 560.0)
                .toDouble();
            final height = (width * 1.2).clamp(340.0, 620.0).toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _DeckHeader(
                        index: _index,
                        total: _cards.length,
                        validated: _validatedCards.contains(card.id),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: width,
                        height: height,
                        child: FlipCardWidget(
                          key: ValueKey<String>(
                            'phase10-flip-${card.id}',
                          ),
                          semanticLabel:
                              card.semanticLabel ?? 'Interactive flashcard',
                          onFaceChanged: _onFaceChanged,
                          onSwipe: _onSwipe,
                          front: _CardFace(
                            card: card,
                            face: Flashcard3DFace.front,
                            surface: surface,
                            border: border,
                            validated: _validatedCards.contains(card.id),
                            onAudio: widget.onAudio ?? _requestTargetSpeech,
                          ),
                          back: _CardFace(
                            card: card,
                            face: Flashcard3DFace.back,
                            surface: surface,
                            border: border,
                            validated: _validatedCards.contains(card.id),
                            onAudio: widget.onAudio ?? _requestTargetSpeech,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _DeckControls(
                        onPrevious: () => _moveBy(-1),
                        onNext: () => _moveBy(1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _requestTargetSpeech(
    Flashcard3DData card,
    Flashcard3DFace face,
  ) {
    final runtime = LifeFeatureRuntime.shared;
    final target = runtime.snapshot.targetLocale;
    final language = face == Flashcard3DFace.front
        ? card.frontLanguageCode
        : card.backLanguageCode;
    if (!runtime.isTargetLanguage(language)) return;

    final text = face == Flashcard3DFace.front
        ? card.frontText
        : card.backText;
    if (text.trim().isEmpty) return;

    unawaited(
      _speakSafely(
        runtime: runtime,
        text: text,
        targetLanguageTag: target.languageTag,
      ),
    );
  }

  static Future<void> _speakSafely({
    required LifeFeatureRuntime runtime,
    required String text,
    required String targetLanguageTag,
  }) async {
    try {
      await runtime.requestSpeech(
        text: text,
        languageTag: targetLanguageTag,
      );
    } on Object {
      return;
    }
  }
}

final class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.index,
    required this.total,
    required this.validated,
  });

  final int index;
  final int total;
  final bool validated;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${index + 1} / $total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: validated
                ? const Chip(
                    key: ValueKey<String>('phase10-card-validated'),
                    avatar: Icon(Icons.verified_rounded, size: 18),
                    label: Text('Offline verified'),
                  )
                : const Chip(
                    key: ValueKey<String>('phase10-card-pending'),
                    avatar: Icon(Icons.offline_bolt_rounded, size: 18),
                    label: Text('Offline first'),
                  ),
          ),
        ],
      );
}

final class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.card,
    required this.face,
    required this.surface,
    required this.border,
    required this.validated,
    required this.onAudio,
  });

  final Flashcard3DData card;
  final Flashcard3DFace face;
  final Color surface;
  final Color border;
  final bool validated;
  final FlashcardAudioCallback onAudio;

  bool get _front => face == Flashcard3DFace.front;

  @override
  Widget build(BuildContext context) {
    final text = _front ? card.frontText : card.backText;
    final language =
        _front ? card.frontLanguageCode : card.backLanguageCode;
    final supporting = _front
        ? card.frontSupportingText
        : card.backSupportingText;
    final grammar = <String>[
      if (card.article != null && card.article!.trim().isNotEmpty)
        'Artikel: ${card.article}',
      if (card.frontSupportingText != null &&
          card.frontSupportingText!.trim().isNotEmpty)
        card.frontSupportingText!.trim(),
    ].join(' • ');

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: _front ? AppColors.primary.withAlpha(130) : border,
      glowColor: _front ? AppColors.primary : AppColors.secondary,
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppDirectionalText(
                  text,
                  languageCode: language,
                  textAlign: TextAlign.center,
                  style: AppTypography.display,
                ),
                if (supporting != null &&
                    supporting.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  AppDirectionalText(
                    supporting,
                    languageCode: language,
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ],
                if (!_front && grammar.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Divider(color: border),
                  const SizedBox(height: 10),
                  AppDirectionalText(
                    grammar,
                    languageCode: card.frontLanguageCode,
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    validated
                        ? 'Validated locally • no network'
                        : 'Validation runs on first reveal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: AppAudioButton(
              onPressed: () => onAudio(card, face),
              semanticLabel: _front
                  ? 'Listen to card text'
                  : 'Listen to translation when it is the target language',
            ),
          ),
        ],
      ),
    );
  }
}

final class _DeckControls extends StatelessWidget {
  const _DeckControls({
    required this.onPrevious,
    required this.onNext,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton.filledTonal(
            onPressed: onPrevious,
            tooltip: 'Previous card',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 18),
          Text(
            'Tap: flip • Swipe: learn',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: 18),
          IconButton.filledTonal(
            onPressed: onNext,
            tooltip: 'Next card',
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      );
}
