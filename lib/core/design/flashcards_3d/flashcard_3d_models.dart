import 'package:flutter/foundation.dart';

enum Flashcard3DFace { front, back }

enum FlashcardSwipeDirection { left, right, up, down }

@immutable
final class Flashcard3DData {
  const Flashcard3DData({
    required this.id,
    required this.frontText,
    required this.backText,
    this.frontLanguageCode = 'de',
    this.backLanguageCode = 'ar',
    this.article,
    this.frontSupportingText,
    this.backSupportingText,
    this.semanticLabel,
  }) : assert(id != '');

  final String id;
  final String frontText;
  final String backText;
  final String frontLanguageCode;
  final String backLanguageCode;
  final String? article;
  final String? frontSupportingText;
  final String? backSupportingText;
  final String? semanticLabel;
}

typedef FlashcardSwipeCallback = void Function(
  FlashcardSwipeDirection direction,
  Flashcard3DData card,
  int index,
);

typedef FlashcardIndexChanged = void Function(
  Flashcard3DData card,
  int index,
);

typedef FlashcardAudioCallback = void Function(
  Flashcard3DData card,
  Flashcard3DFace face,
);
