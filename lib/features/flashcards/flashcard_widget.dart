import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';
import 'card_physics_helper.dart';

/// Screen-independent, multiscript flashcard. No review mutations happen here.
class FlashcardWidget extends StatelessWidget {
  final LexicalEntry entry;
  final Animation<double> animation;
  final VoidCallback? onFlip;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.onReviewed,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnswering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _controller.value = 0;
      _isAnswering = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  Future<void> _submitRating(int rating) async {
    if (_isAnswering) return;
    setState(() {
      _isAnswering = true;
    });

    try {
      SrsRating srsRating = SrsRating.good;
      switch (rating) {
        case 0:
        case 1:
          srsRating = SrsRating.hard;
          break;
        case 2:
          srsRating = SrsRating.good;
          break;
        case 3:
          srsRating = SrsRating.easy;
          break;
      }

      ProductionSrsEngine.processReview(
        currentIntervalDays: widget.card.currentIntervalDays,
        currentEaseFactor: widget.card.currentEaseFactor,
        currentRepetitions: widget.card.currentRepetitions,
        rating: srsRating,
      );

      await widget.onReviewed(
          widget.card.id, rating, widget.card.sourceIso, widget.card.targetIso);
    } finally {
      if (mounted) {
        setState(() {
          _isAnswering = false;
        });
      }
    }
  }

  Widget _buildFront() {
    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        key: const ValueKey('flashcard_front'),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Directionality(
              textDirection: widget.card.sourceIso == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Text(
                widget.card.frontText,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey('flashcard_back'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: widget.card.targetIso == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Text(
              widget.card.backText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.card.example != null)
            Directionality(
              textDirection: widget.card.targetIso == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Text(
                widget.card.example!,
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.card.translation != null)
            Directionality(
              textDirection: widget.card.sourceIso == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Text(
                widget.card.translation!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.card.hasAudio)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.volume_up, color: Colors.blue),
            ),
          const SizedBox(height: 32),
          if (_isAnswering)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => _submitRating(0),
                    child: const Text('Wrong')),
                ElevatedButton(
                    onPressed: () => _submitRating(1),
                    child: const Text('Skip')),
                ElevatedButton(
                    onPressed: () => _submitRating(2),
                    child: const Text('Correct')),
                ElevatedButton(
                    onPressed: () => _submitRating(3),
                    child: const Text('Easy')),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final back = CardPhysicsHelper.isBackSide(animation.value);
        return Semantics(
          button: onFlip != null,
          label: 'اقلب البطاقة',
          child: GestureDetector(
            key: const Key('flashcard-toggle'),
            onTap: onFlip,
            child: Transform(
              alignment: Alignment.center,
              transform:
                  CardPhysicsHelper.compute3dFlipTransform(animation.value),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(back ? math.pi : 0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: back ? _back() : _front(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _front() => <Widget>[
        AppDirectionalText(entry.targetTerm,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        if (entry.partOfSpeech.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          AppDirectionalText(entry.partOfSpeech, textAlign: TextAlign.center),
        ],
      ];

  List<Widget> _back() => <Widget>[
        AppDirectionalText(entry.sourceMeaning,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        if (entry.targetExample.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          AppDirectionalText(entry.targetExample, textAlign: TextAlign.center),
        ],
        if (entry.sourceExampleTranslation.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          AppDirectionalText(entry.sourceExampleTranslation,
              textAlign: TextAlign.center),
        ],
      ];
}
