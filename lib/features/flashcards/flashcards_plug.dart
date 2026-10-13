import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/plugins/feature_plug.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'flashcard_session.dart';

/// Gated production entry. No fake success through an in-memory SRS journal.
class FlashcardsPlug implements FeaturePlug {
  final List<FlashcardReviewItem>? reviewItems;
  final ReviewCommandPort? reviewPort;

  const FlashcardsPlug({this.reviewItems, this.reviewPort});

  @override
  String get id => 'flashcards_core';

  @override
  String get displayName => 'البطاقات التفاعلية';

  @override
  Widget buildEntry(BuildContext context) => FeatureBoundary(
    featureName: displayName,
    child: reviewPort != null && reviewItems != null && reviewItems!.isNotEmpty
        ? FlashcardSessionWidget(items: reviewItems!, reviewPort: reviewPort!)
        : const _FlashcardsContainer(),
  );

  /// Legacy callers get a clear failure instead of a non-durable write.
  /// The session must provide an ID that remains stable across process death.
  @Deprecated('Use FlashcardSessionWidget with a durable reviewPort')
  static Future<void> dispatchReview({
    required String cardId,
    required int rating,
    String sourceIso = 'de',
    String targetIso = 'ar',
    ReviewCommandPort? reviewPort,
    String? reviewEventId,
    String? semanticVersion,
    int? pairEpoch,
  }) async {
    if (reviewPort == null ||
        reviewEventId == null ||
        semanticVersion == null ||
        pairEpoch == null ||
        rating < 0 ||
        rating > 3) {
      throw StateError('A durable, versioned review writer is required');
    }
    await reviewPort.submit(ReviewCommand(
      reviewId: reviewEventId,
      sourceLanguageId: sourceIso,
      targetLanguageId: targetIso,
      semanticVersion: semanticVersion,
      cardId: cardId,
      facetKey: 'lexeme',
      pairEpoch: pairEpoch,
      rating: ReviewRating.values[rating],
      hinted: false,
    ));
  }
}

class _FlashcardsContainer extends StatelessWidget {
  const _FlashcardsContainer();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('البطاقات جاهزة بعد ربط التخزين المحلي الآمن'),
    ),
  );
}
