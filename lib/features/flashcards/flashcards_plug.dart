import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/plugins/feature_plug.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/design/bidi_text_isolator.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/design_system/app_audio_button.dart';
import 'card_physics_helper.dart';

class FlashcardsPlug implements FeaturePlug {
  final String sourceLocale;
  final String targetLocale;

  FlashcardsPlug({
    this.sourceLocale = 'de-DE',
    this.targetLocale = 'ar-SA',
  });

  @override
  String get id => 'flashcards_core';

  @override
  String get displayName => 'البطاقات التفاعلية';

  @override
  Widget buildEntry(BuildContext context) {
    return FeatureBoundary(
      featureName: displayName,
      child: _FlashcardsContainer(
        sourceLocale: sourceLocale,
        targetLocale: targetLocale,
      ),
    );
  }

  /// إرسال حدث مراجعة للنواة دون قلق بشأن قاعدة البيانات أو مسارات التخزين
  static Future<void> dispatchReview({
    required String cardId,
    required int rating,
    String sourceIso = 'de',
    String targetIso = 'ar',
  }) async {
    await SrsCompatBridge.instance.recordReviewCompat(
      contentKey: cardId,
      rating: rating,
      sourceIso: sourceIso,
      targetIso: targetIso,
    );
  }
}

enum FlashcardState { loading, front, back, completed, error }

class _FlashcardsContainer extends StatefulWidget {
  final String sourceLocale;
  final String targetLocale;

  const _FlashcardsContainer({
    required this.sourceLocale,
    required this.targetLocale,
  });

  @override
  State<_FlashcardsContainer> createState() => _FlashcardsContainerState();
}

class _FlashcardsContainerState extends State<_FlashcardsContainer> {
  FlashcardState _state = FlashcardState.loading;
  List<LexicalEntry> _entries = [];
  int _currentIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _state = FlashcardState.loading;
    });

    final allEntries = LexicalRepository.getEntriesForPair(
      sourceLocale: widget.sourceLocale,
      targetLocale: widget.targetLocale,
    );

    _entries = List.from(allEntries);

    if (_entries.isNotEmpty) {
      _state = FlashcardState.front;
    } else {
      _state = FlashcardState.error;
    }
  }

  void _handleReview(int rating) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final entry = _entries[_currentIndex];

    if (rating != -1) { // -1 means skipped
      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: entry.id,
        rating: rating,
        sourceIso: entry.sourceLocale.split('-')[0],
        targetIso: entry.targetLocale.split('-')[0],
      );

      // Repeated-answer flow: if rating is 0 (hard/again), we should repeat the card later.
      if (rating == 0) {
        _entries.add(entry);
      }
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (_currentIndex < _entries.length - 1) {
          _currentIndex++;
          _state = FlashcardState.front;
        } else {
          _state = FlashcardState.completed;
        }
      });
    }
  }

  void _flipCard() {
    if (_state == FlashcardState.front) {
      setState(() {
        _state = FlashcardState.back;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == FlashcardState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_state == FlashcardState.error) {
      return const Center(child: Text('لا توجد بطاقات متاحة'));
    }
    if (_state == FlashcardState.completed) {
      return const Center(child: Text('اكتملت المراجعة'));
    }

    final entry = _entries[_currentIndex];

    return FlashcardView(
      entry: entry,
      state: _state,
      isSubmitting: _isSubmitting,
      onFlip: _flipCard,
      onRate: _handleReview,
    );
  }
}

class FlashcardView extends StatefulWidget {
  final LexicalEntry entry;
  final FlashcardState state;
  final bool isSubmitting;
  final VoidCallback onFlip;
  final ValueChanged<int> onRate;

  const FlashcardView({
    Key? key,
    required this.entry,
    required this.state,
    required this.isSubmitting,
    required this.onFlip,
    required this.onRate,
  }) : super(key: key);

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void didUpdateWidget(FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == FlashcardState.back && oldWidget.state != FlashcardState.back) {
      _animationController.forward();
    } else if (widget.state == FlashcardState.front && oldWidget.state != FlashcardState.front) {
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final transform = CardPhysicsHelper.compute3dFlipTransform(_animation.value);
        final isBack = CardPhysicsHelper.isBackSide(_animation.value);

        return GestureDetector(
          onTap: !isBack ? widget.onFlip : null,
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isBack ? _buildBack() : _buildFront(),
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    final textDir = LanguageBiDiHelper.getDirection(widget.entry.sourceLocale);
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(minHeight: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Directionality(
              textDirection: textDir,
              child: Text(
                BiDiTextIsolator.wrapDirectional(widget.entry.sourceMeaning, isRtl: textDir == TextDirection.rtl),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    final textDir = LanguageBiDiHelper.getDirection(widget.entry.targetLocale);
    return Transform(
      transform: Matrix4.rotationY(3.141592653589793), // Pi
      alignment: Alignment.center,
      child: Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(minHeight: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: textDir,
                    child: Text(
                      BiDiTextIsolator.wrapDirectional(widget.entry.targetTerm, isRtl: textDir == TextDirection.rtl),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppAudioButton(
                    onPressed: () {
                      OfflineAudioDispatcher.speakText(
                        text: widget.entry.targetTerm,
                        bcp47Locale: widget.entry.targetLocale,
                      );
                    },
                    semanticLabel: 'استمع',
                  ),
                ],
              ),
              if (widget.entry.targetExample.isNotEmpty) ...[
                const SizedBox(height: 16),
                Directionality(
                  textDirection: textDir,
                  child: Text(
                    BiDiTextIsolator.wrapDirectional(widget.entry.targetExample, isRtl: textDir == TextDirection.rtl),
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.entry.sourceExampleTranslation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: LanguageBiDiHelper.getDirection(widget.entry.sourceLocale),
                    child: Text(
                      BiDiTextIsolator.wrapDirectional(widget.entry.sourceExampleTranslation, isRtl: LanguageBiDiHelper.getDirection(widget.entry.sourceLocale) == TextDirection.rtl),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: widget.isSubmitting ? null : () => widget.onRate(-1), // Skip
                    child: const Text('تخطي'),
                  ),
                  ElevatedButton(
                    onPressed: widget.isSubmitting ? null : () => widget.onRate(0), // Hard / Again
                    child: const Text('صعب'),
                  ),
                  ElevatedButton(
                    onPressed: widget.isSubmitting ? null : () => widget.onRate(1), // Good
                    child: const Text('جيد'),
                  ),
                  ElevatedButton(
                    onPressed: widget.isSubmitting ? null : () => widget.onRate(2), // Easy
                    child: const Text('سهل'),
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
