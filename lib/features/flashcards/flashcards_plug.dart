import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/plugins/feature_plug.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

class FlashcardsPlug implements FeaturePlug {
  @override
  String get id => 'flashcards_core';

  @override
  String get displayName => 'البطاقات التفاعلية';

  @override
  Widget buildEntry(BuildContext context) {
    return FeatureBoundary(
      featureName: displayName,
      child: _FlashcardsContainer(),
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

class _FlashcardsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'جاهز للتعلم التكيفي',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
