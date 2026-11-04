import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/plugins/feature_plug.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

import 'models.dart';
import 'card_physics_helper.dart';

class FlashcardsPlug implements FeaturePlug {
  final List<FlashcardItem> items;
  final VoidCallback? onComplete;

  const FlashcardsPlug({
    this.items = const [],
    this.onComplete,
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
        items: items,
        onComplete: onComplete,
      ),
    );
  }

  /// إرسال حدث مراجعة للنواة دون قلق بشأن قاعدة البيانات أو مسارات التخزين
  static Future<void> dispatchReview({
    required String cardId,
    required int rating,
    String sourceIso = 'de',
    String targetIso = 'ar',
    ReviewCommandPort? commandPort,
  }) async {
    if (commandPort != null) {
      ReviewRating enumRating;
      switch (rating) {
        case 0:
          enumRating = ReviewRating.again;
          break;
        case 1:
          enumRating = ReviewRating.hard;
          break;
        case 2:
          enumRating = ReviewRating.good;
          break;
        case 3:
          enumRating = ReviewRating.easy;
          break;
        default:
          enumRating = ReviewRating.good;
          break;
      }
      final command = ReviewCommand(
        reviewId: 'REV_${cardId}_${DateTime.now().millisecondsSinceEpoch}',
        sourceLanguageId: sourceIso,
        targetLanguageId: targetIso,
        cardId: cardId,
        facetKey: 'flashcard',
        pairEpoch: DateTime.now().millisecondsSinceEpoch,
        rating: enumRating,
        hinted: false,
      );
      await commandPort.submit(command);
      return;
    }
  }
}

class _FlashcardsContainer extends StatefulWidget {
  final List<FlashcardItem> items;
  final VoidCallback? onComplete;

  const _FlashcardsContainer({
    required this.items,
    this.onComplete,
  });

  @override
  State<_FlashcardsContainer> createState() => _FlashcardsContainerState();
}

class _FlashcardsContainerState extends State<_FlashcardsContainer> {
  int _currentIndex = 0;

  void _nextCard() {
    setState(() {
      _currentIndex++;
    });
    if (_currentIndex >= widget.items.length) {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.items.length) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'جاهز للتعلم التكيفي',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('البطاقات تنتظر ربط التخزين المحلي الآمن'),
          ],
        ),
      );
    }

    return _FlashcardWidget(
      key: ValueKey(widget.items[_currentIndex].id),
      item: widget.items[_currentIndex],
      onGraded: _nextCard,
    );
  }
}

class _FlashcardWidget extends StatefulWidget {
  final FlashcardItem item;
  final VoidCallback onGraded;

  const _FlashcardWidget({
    super.key,
    required this.item,
    required this.onGraded,
  });

  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  Future<void> _handleGrade(int rating) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: widget.item.id,
        rating: rating,
        sourceIso: widget.item.sourceIso,
        targetIso: widget.item.targetIso,
      );
      widget.onGraded();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final transform =
            CardPhysicsHelper.compute3dFlipTransform(_controller.value);
        final isBack = CardPhysicsHelper.isBackSide(_controller.value);

        return GestureDetector(
          onTap: isBack ? null : _flipCard,
          child: Transform(
            transform: transform,
            alignment: FractionalOffset.center,
            child: isBack ? _buildBack() : _buildFront(),
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(minHeight: 200, minWidth: 300),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: _getTextDirection(widget.item.sourceIso),
              child: Text(
                widget.item.text,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.item.hasAudio) ...[
              const SizedBox(height: 16),
              const Icon(Icons.volume_up, size: 24, color: Colors.blueGrey),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    // We flip the back content so it's not mirrored since the container is rotated by pi.
    return Transform(
      transform: Matrix4.rotationY(3.141592653589793), // pi
      alignment: Alignment.center,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(minHeight: 200, minWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Directionality(
                textDirection: _getTextDirection(widget.item.sourceIso),
                child: Text(
                  widget.item.text,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: _getTextDirection(widget.item.targetIso),
                child: Text(
                  widget.item.translation,
                  style:
                      const TextStyle(fontSize: 20, color: Colors.blueAccent),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.item.example != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: _getTextDirection(widget.item.sourceIso),
                  child: Text(
                    widget.item.example!,
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.item.exampleTranslation != null) ...[
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: _getTextDirection(widget.item.targetIso),
                    child: Text(
                      widget.item.exampleTranslation!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleGrade(0),
                    child: const Text('تخطي'),
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleGrade(1),
                    child: const Text('خطأ'),
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleGrade(3),
                    child: const Text('تكرار'),
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleGrade(4),
                    child: const Text('صحيح'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextDirection _getTextDirection(String iso) {
    return iso == 'ar' || iso == 'he' || iso == 'fa'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
