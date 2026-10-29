import 'package:flutter/material.dart';

import '../../../design_system/app_audio_button.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import 'flashcard_3d_animation.dart';
import 'flashcard_3d_models.dart';
import 'flashcard_gesture_controller.dart';

abstract final class Flashcard3DUiTokens {
  static const double outerInset = 16;
  static const double sectionGap = 16;
  static const double cardInset = 22;
  static const double compactGap = 8;
  static const double actionGap = 12;
  static const double maxCardWidth = 520;
}

final class Flashcard3DMasterHub extends StatefulWidget {
  const Flashcard3DMasterHub({
    required this.cards,
    this.initialIndex = 0,
    this.loop = true,
    this.onSwipe,
    this.onCardChanged,
    this.onAudio,
    super.key,
  });

  final List<Flashcard3DData> cards;
  final int initialIndex;
  final bool loop;
  final FlashcardSwipeCallback? onSwipe;
  final FlashcardIndexChanged? onCardChanged;
  final FlashcardAudioCallback? onAudio;

  @override
  State<Flashcard3DMasterHub> createState() => _Flashcard3DMasterHubState();
}

final class _Flashcard3DMasterHubState extends State<Flashcard3DMasterHub> {
  late final FlashcardGestureController _gestureController;
  late int _index;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _gestureController = FlashcardGestureController();
    _index = _safeInitialIndex();
  }

  @override
  void didUpdateWidget(covariant Flashcard3DMasterHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards.isEmpty) {
      _index = 0;
      _isFlipped = false;
      _gestureController.cancelDrag();
      return;
    }
    if (_index >= widget.cards.length) {
      _index = widget.cards.length - 1;
      _isFlipped = false;
      _gestureController.cancelDrag();
    }
  }

  @override
  void dispose() {
    _gestureController.dispose();
    super.dispose();
  }

  int _safeInitialIndex() {
    if (widget.cards.isEmpty) return 0;
    return widget.initialIndex.clamp(0, widget.cards.length - 1).toInt();
  }

  void _toggleFlip() {
    if (widget.cards.isEmpty) return;
    setState(() => _isFlipped = !_isFlipped);
  }

  void _moveBy(int delta) {
    if (widget.cards.isEmpty) return;

    final length = widget.cards.length;
    final raw = _index + delta;
    final next = widget.loop
        ? ((raw % length) + length) % length
        : raw.clamp(0, length - 1).toInt();

    if (next == _index) {
      setState(() => _isFlipped = false);
      return;
    }

    setState(() {
      _index = next;
      _isFlipped = false;
    });
    widget.onCardChanged?.call(widget.cards[_index], _index);
  }

  void _handleSwipe(FlashcardSwipeDirection direction) {
    if (widget.cards.isEmpty) return;
    final activeCard = widget.cards[_index];
    final activeIndex = _index;
    widget.onSwipe?.call(direction, activeCard, activeIndex);

    switch (direction) {
      case FlashcardSwipeDirection.left:
        _moveBy(1);
        break;
      case FlashcardSwipeDirection.right:
        _moveBy(-1);
        break;
      case FlashcardSwipeDirection.up:
      case FlashcardSwipeDirection.down:
        setState(() => _isFlipped = false);
        break;
    }
  }

  Color _articleColor(String? article) => switch (article?.toLowerCase()) {
        'der' => AppColors.articleDer,
        'die' => AppColors.articleDie,
        'das' => AppColors.articleDas,
        'plural' => AppColors.articleOther,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    if (widget.cards.isEmpty) {
      return Center(
        child: AppGlassCard(
          backgroundColor: surface,
          borderColor: border,
          child: AppDirectionalText(
            'لا توجد بطاقات متاحة حاليًا.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ),
      );
    }

    final card = widget.cards[_index];

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : Flashcard3DUiTokens.maxCardWidth;
          final cardWidth = (availableWidth -
                  (Flashcard3DUiTokens.outerInset * 2))
              .clamp(240.0, Flashcard3DUiTokens.maxCardWidth)
              .toDouble();
          final cardHeight = (cardWidth * 1.18).clamp(300.0, 560.0).toDouble();
          final viewport = Size(cardWidth, cardHeight);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Flashcard3DUiTokens.outerInset),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Flashcard3DUiTokens.maxCardWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _DeckHeader(
                      index: _index,
                      total: widget.cards.length,
                      isFlipped: _isFlipped,
                    ),
                    const SizedBox(height: Flashcard3DUiTokens.sectionGap),
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: GestureDetector(
                        key: const ValueKey<String>(
                          'flashcard-gesture-surface',
                        ),
                        behavior: HitTestBehavior.opaque,
                        onTap: _toggleFlip,
                        onPanStart: (_) => _gestureController.beginDrag(),
                        onPanUpdate: (details) =>
                            _gestureController.updateDrag(details.delta),
                        onPanCancel: _gestureController.cancelDrag,
                        onPanEnd: (_) {
                          final direction =
                              _gestureController.endDrag(viewport);
                          if (direction != null) {
                            _handleSwipe(direction);
                          }
                        },
                        child: Semantics(
                          button: true,
                          label: card.semanticLabel ??
                              'Interactive flashcard ${_index + 1} '
                                  'of ${widget.cards.length}',
                          hint:
                              'Tap to flip. Swipe left or right to navigate.',
                          child: AnimatedBuilder(
                            animation: _gestureController,
                            builder: (context, child) {
                              final offset = _gestureController.dragOffset;
                              final dragFraction =
                                  _gestureController.horizontalFraction(
                                viewport,
                              );

                              return Transform.translate(
                                offset: Offset(
                                  offset.dx * .72,
                                  offset.dy * .36,
                                ),
                                child: AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 220),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: .97,
                                        end: 1,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                                  child: Flashcard3DRenderer(
                                    key: ValueKey<String>(card.id),
                                    isFlipped: _isFlipped,
                                    dragFraction: dragFraction,
                                    front: _CardFace(
                                      card: card,
                                      face: Flashcard3DFace.front,
                                      surface: surface,
                                      border: border,
                                      articleColor:
                                          _articleColor(card.article),
                                      onAudio: widget.onAudio,
                                    ),
                                    back: _CardFace(
                                      card: card,
                                      face: Flashcard3DFace.back,
                                      surface: surface,
                                      border: border,
                                      articleColor:
                                          _articleColor(card.article),
                                      onAudio: widget.onAudio,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Flashcard3DUiTokens.sectionGap),
                    _AccessibleControls(
                      canGoPrevious: widget.loop || _index > 0,
                      canGoNext:
                          widget.loop || _index < widget.cards.length - 1,
                      isFlipped: _isFlipped,
                      onPrevious: () => _moveBy(-1),
                      onFlip: _toggleFlip,
                      onNext: () => _moveBy(1),
                    ),
                    const SizedBox(height: Flashcard3DUiTokens.compactGap),
                    AppDirectionalText(
                      'Tippen: drehen • Links/Rechts: navigieren • '
                      'Oben/Unten: Lernaktion',
                      languageCode: 'de',
                      textAlign: TextAlign.center,
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      'اضغط للقلب • اسحب يمينًا/يسارًا للتنقل • '
                      'أعلى/أسفل لإجراء تعليمي',
                      languageCode: 'ar',
                      textAlign: TextAlign.center,
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.index,
    required this.total,
    required this.isFlipped,
  });

  final int index;
  final int total;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: AppDirectionalText(
              isFlipped ? 'Rückseite' : 'Vorderseite',
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            '${index + 1} / $total',
            style: AppTypography.label,
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
    required this.articleColor,
    required this.onAudio,
  });

  final Flashcard3DData card;
  final Flashcard3DFace face;
  final Color surface;
  final Color border;
  final Color articleColor;
  final FlashcardAudioCallback? onAudio;

  @override
  Widget build(BuildContext context) {
    final isFront = face == Flashcard3DFace.front;
    final text = isFront ? card.frontText : card.backText;
    final languageCode =
        isFront ? card.frontLanguageCode : card.backLanguageCode;
    final supporting =
        isFront ? card.frontSupportingText : card.backSupportingText;

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: isFront ? articleColor.withAlpha(150) : border,
      glowColor: isFront ? articleColor : AppColors.secondary,
      padding: const EdgeInsets.all(Flashcard3DUiTokens.cardInset),
      child: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppDirectionalText(
                  text,
                  languageCode: languageCode,
                  textAlign: TextAlign.center,
                  style: AppTypography.display,
                ),
                if (isFront &&
                    card.article != null &&
                    card.article!.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: Flashcard3DUiTokens.actionGap),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: articleColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: AppDirectionalText(
                        card.article!,
                        languageCode: 'de',
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                if (supporting != null &&
                    supporting.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: Flashcard3DUiTokens.actionGap),
                  AppDirectionalText(
                    supporting,
                    languageCode: languageCode,
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ],
              ],
            ),
          ),
          if (onAudio != null)
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: AppAudioButton(
                onPressed: () => onAudio!(card, face),
                semanticLabel: isFront
                    ? 'Listen to the front of the flashcard'
                    : 'Listen to the back of the flashcard',
              ),
            ),
        ],
      ),
    );
  }
}

final class _AccessibleControls extends StatelessWidget {
  const _AccessibleControls({
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isFlipped,
    required this.onPrevious,
    required this.onFlip,
    required this.onNext,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final bool isFlipped;
  final VoidCallback onPrevious;
  final VoidCallback onFlip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton.filledTonal(
            tooltip: 'Previous card',
            onPressed: canGoPrevious ? onPrevious : null,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: Flashcard3DUiTokens.actionGap),
          FilledButton.icon(
            onPressed: onFlip,
            icon: const Icon(Icons.flip_rounded),
            label: Text(isFlipped ? 'Front' : 'Flip'),
          ),
          const SizedBox(width: Flashcard3DUiTokens.actionGap),
          IconButton.filledTonal(
            tooltip: 'Next card',
            onPressed: canGoNext ? onNext : null,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      );
}
