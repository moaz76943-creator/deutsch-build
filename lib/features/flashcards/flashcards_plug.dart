import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/plugins/feature_plug.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

import 'package:deutsch_bilarabi/features/flashcards/flashcard_models.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcard_widget.dart';

class FlashcardsPlug implements FeaturePlug {
  final FlashcardData? initialCard;
  final ReviewCommandPort? commandPort;

  const FlashcardsPlug({this.initialCard, this.commandPort});
  @override
  String get id => 'flashcards_core';

  @override
  String get displayName => 'البطاقات التفاعلية';

  @override
  Widget buildEntry(BuildContext context) {
    return FeatureBoundary(
      featureName: displayName,
      child: _FlashcardsContainer(card: initialCard, commandPort: commandPort),
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
        case 0: enumRating = ReviewRating.again; break;
        case 1: enumRating = ReviewRating.hard; break;
        case 2: enumRating = ReviewRating.good; break;
        case 3: enumRating = ReviewRating.easy; break;
        default: enumRating = ReviewRating.good; break;
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
    } else {
      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: cardId,
        rating: rating,
        sourceIso: sourceIso,
        targetIso: targetIso,
      );
    }
  }
}

class _FlashcardsContainer extends StatelessWidget {
  final FlashcardData? card;
  final ReviewCommandPort? commandPort;

  const _FlashcardsContainer({Key? key, this.card, this.commandPort}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card != null) {
      return FlashcardWidget(
        card: card!,
        onReviewed: (cardId, rating, sourceIso, targetIso) => FlashcardsPlug.dispatchReview(cardId: cardId, rating: rating, sourceIso: sourceIso, targetIso: targetIso, commandPort: commandPort),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'جاهز للتعلم التكيفي',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
