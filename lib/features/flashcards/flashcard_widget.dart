import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/features/flashcards/card_physics_helper.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcard_models.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';

class FlashcardWidget extends StatefulWidget {
  final FlashcardData card;
  final Future<void> Function(String cardId, int rating, String sourceIso, String targetIso) onReviewed;

  const FlashcardWidget({
    Key? key,
    required this.card,
    required this.onReviewed,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnswering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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

      await widget.onReviewed(widget.card.id, rating, widget.card.sourceIso, widget.card.targetIso);
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Directionality(
              textDirection: widget.card.sourceIso == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                widget.card.frontText,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: widget.card.targetIso == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              widget.card.backText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.card.example != null)
            Directionality(
              textDirection: widget.card.targetIso == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                widget.card.example!,
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.card.translation != null)
            Directionality(
              textDirection: widget.card.sourceIso == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
                ElevatedButton(onPressed: () => _submitRating(0), child: const Text('Wrong')),
                ElevatedButton(onPressed: () => _submitRating(1), child: const Text('Skip')),
                ElevatedButton(onPressed: () => _submitRating(2), child: const Text('Correct')),
                ElevatedButton(onPressed: () => _submitRating(3), child: const Text('Easy')),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final transform = CardPhysicsHelper.compute3dFlipTransform(_animation.value);
        final isBack = CardPhysicsHelper.isBackSide(_animation.value);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(3.1415926535897932), // pi
                  alignment: Alignment.center,
                  child: _buildBack(),
                )
              : _buildFront(),
        );
      },
    );
  }
}
