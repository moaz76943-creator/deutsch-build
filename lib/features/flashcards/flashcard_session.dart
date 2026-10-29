import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcard_widget.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcards_plug.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';

class FlashcardSessionWidget extends StatefulWidget {
  final List<LexicalEntry> initialEntries;

  const FlashcardSessionWidget({
    Key? key,
    required this.initialEntries,
  }) : super(key: key);

  @override
  _FlashcardSessionWidgetState createState() => _FlashcardSessionWidgetState();
}

class _FlashcardSessionWidgetState extends State<FlashcardSessionWidget> with SingleTickerProviderStateMixin {
  late List<LexicalEntry> _queue;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _isGrading = false;

  @override
  void initState() {
    super.initState();
    _queue = List.from(widget.initialEntries);
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_flipController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _handleGrade(SrsRating rating) async {
    if (_isGrading || _queue.isEmpty) return;
    setState(() {
      _isGrading = true;
    });

    final currentEntry = _queue.first;

    // Convert SrsRating to integer for SrsCompatBridge
    int ratingInt;
    switch (rating) {
      case SrsRating.hard:
        ratingInt = 1;
        break;
      case SrsRating.good:
        ratingInt = 2;
        break;
      case SrsRating.easy:
        ratingInt = 3;
        break;
    }

    try {
      await FlashcardsPlug.dispatchReview(
        cardId: currentEntry.id,
        rating: ratingInt,
        sourceIso: currentEntry.sourceLocale,
        targetIso: currentEntry.targetLocale,
      );

      // Animation & state reset for next card
      if (mounted) {
        setState(() {
          _queue.removeAt(0);
          if (rating == SrsRating.hard) {
             _queue.add(currentEntry);
          }
          _isFlipped = false;
          _flipController.reset();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGrading = false;
        });
      }
    }
  }

  void _skipCard() {
    if (_isGrading || _queue.isEmpty) return;
    setState(() {
      final entry = _queue.removeAt(0);
      _queue.add(entry);
      _isFlipped = false;
      _flipController.reset();
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return const Center(child: Text('Session Complete!'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Cards left: ${_queue.length}'),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FlashcardWidget(
              entry: _queue.first,
              animation: _flipAnimation,
              onFlip: _flipCard,
            ),
          ),
        ),
        if (_isFlipped)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isGrading ? null : () => _handleGrade(SrsRating.hard),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Hard', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _isGrading ? null : () => _handleGrade(SrsRating.good),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Good', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _isGrading ? null : () => _handleGrade(SrsRating.easy),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Easy', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )
        else
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: TextButton(onPressed: _skipCard, child: const Text('Skip')),
           )
      ],
    );
  }
}
