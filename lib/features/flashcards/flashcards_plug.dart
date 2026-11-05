import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/plugins/feature_plug.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'flashcard_session.dart';

class FlashcardsPlug implements FeaturePlug {
  final List<LexicalEntry> entries;
  final VoidCallback? onComplete;

  const FlashcardsPlug({
    this.entries = const [],
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
      child: FlashcardSessionWidget(
        initialEntries: entries,
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
    await SrsCompatBridge.instance.recordReviewCompat(
      contentKey: cardId,
      rating: rating,
      sourceIso: sourceIso,
      targetIso: targetIso,
    );
  }
}
