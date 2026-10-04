import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/phase3_integration/life_feature_runtime.dart';

import '../../core/content_contract.dart';
import '../../core/curriculum/advanced_vocabulary.dart';
import '../../core/design/flashcards_3d/flashcard_3d_master_hub.dart';
import '../../core/design/flashcards_3d/flashcard_3d_models.dart';

abstract final class VocabularyProjectionFactory {
  static VocabularyFlashcardProjection fromContent(LearningContent item) {
    final marker = item.grammaticalMarker.trim();
    final normalizedMarker = marker.toLowerCase();
    final article = const <String>{'der', 'die', 'das', 'plural'}
            .contains(normalizedMarker)
        ? normalizedMarker
        : null;
    final supporting = <String>[
      if (marker.isNotEmpty) marker,
      if (item.pluralForm.trim().isNotEmpty)
        'Plural: ${item.pluralForm.trim()}',
    ].join(' • ');

    return VocabularyFlashcardProjection(
      id: item.id,
      frontText: item.sourceText,
      backText: item.translationText,
      frontLanguageCode: 'de',
      backLanguageCode: 'ar',
      article: article,
      frontSupportingText:
          supporting.isEmpty ? item.exampleText : supporting,
      backSupportingText: item.exampleTranslationText,
      semanticLabel: '${item.topic}: ${item.sourceText}',
    );
  }

  static List<VocabularyFlashcardProjection> fromContentList(
    Iterable<LearningContent> items,
  ) =>
      List<VocabularyFlashcardProjection>.unmodifiable(
        items.map(fromContent),
      );
}

abstract final class VocabularyFlashcard3DAdapter {
  static Flashcard3DData fromProjection(
    VocabularyFlashcardProjection projection,
  ) =>
      Flashcard3DData(
        id: projection.id,
        frontText: projection.frontText,
        backText: projection.backText,
        frontLanguageCode: projection.frontLanguageCode,
        backLanguageCode: projection.backLanguageCode,
        article: projection.article,
        frontSupportingText: projection.frontSupportingText,
        backSupportingText: projection.backSupportingText,
        semanticLabel: projection.semanticLabel,
      );

  static List<Flashcard3DData> deck(
    Iterable<VocabularyFlashcardProjection> projections,
  ) =>
      List<Flashcard3DData>.unmodifiable(
        projections.map(fromProjection),
      );
}

final class Phase3FlashcardDeckPage extends StatelessWidget {
  const Phase3FlashcardDeckPage({
    required this.title,
    required this.emptyText,
    required this.projections,
    this.onAudio,
    super.key,
  });

  final String title;
  final String emptyText;
  final List<VocabularyFlashcardProjection> projections;
  final FlashcardAudioCallback? onAudio;

  @override
  Widget build(BuildContext context) {
    final cards = VocabularyFlashcard3DAdapter.deck(projections);
    final effectiveOnAudio = onAudio ?? _requestTargetSpeech;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: cards.isEmpty
          ? Center(child: Text(emptyText))
          : Flashcard3DMasterHub(
              cards: cards,
              onAudio: effectiveOnAudio,
            ),
    );
  }

  void _requestTargetSpeech(
    Flashcard3DData card,
    Flashcard3DFace face,
  ) {
    final runtime = LifeFeatureRuntime.shared;
    final target = runtime.snapshot.targetLocale;
    final faceLanguage =
        face == Flashcard3DFace.front
            ? card.frontLanguageCode
            : card.backLanguageCode;

    if (!_isTargetLanguage(faceLanguage, target.languageCode)) return;

    final text =
        face == Flashcard3DFace.front ? card.frontText : card.backText;
    if (text.trim().isEmpty) return;

    unawaited(
      _speakTargetSafely(
        runtime: runtime,
        text: text,
        targetLanguageTag: target.languageTag,
      ),
    );
  }

  static bool _isTargetLanguage(
    String faceLanguageTag,
    String targetLanguageCode,
  ) {
    final normalizedFace =
        faceLanguageTag.trim().toLowerCase().replaceAll('_', '-');
    final normalizedTarget = targetLanguageCode.trim().toLowerCase();
    return normalizedFace == normalizedTarget ||
        normalizedFace.startsWith('$normalizedTarget-');
  }

  static Future<void> _speakTargetSafely({
    required LifeFeatureRuntime runtime,
    required String text,
    required String targetLanguageTag,
  }) async {
    try {
      await runtime.requestSpeech(
        text: text,
        languageTag: targetLanguageTag,
      );
    } on Object {
      return;
    }
  }

}
