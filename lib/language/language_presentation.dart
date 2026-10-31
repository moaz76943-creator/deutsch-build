import '../models/conversation.dart';

/// Language-aware presentation contract.
///
/// Shared UI may consume this contract without knowing which learning
/// language is configured at the Composition Root.
abstract interface class LanguagePresentation {
  String get targetLanguageName;
  String get pronunciationTooltip;
  String get grammaticalMarkerLabel;
  String get pluralLabel;
  ConversationPresentation get conversation;
  RealWorldLearningPresentation get realWorld;
  PlacementPresentation get placement;
}

/// Presentation copy and safe fallback data for conversation learning.
abstract interface class ConversationPresentation {
  String get targetLanguageName;
  String get targetLanguageInstruction;
  String get speechPermissionError;
  String get defaultSpeechStatus;
  ConversationScenario get fallbackScenario;
}

/// Language-aware presentation data for practical real-world learning.
abstract interface class RealWorldLearningPresentation {
  String get title;
  String get subtitle;
  String get targetLanguageInstruction;
  List<RealWorldScenario> get scenarios;
}

/// One practical scenario displayed by the shared real-world learning shell.
final class RealWorldScenario {
  final String title;
  final String targetText;
  final String sourceText;

  const RealWorldScenario({
    required this.title,
    required this.targetText,
    required this.sourceText,
  });
}

/// Language-aware placement-test presentation data.
abstract interface class PlacementPresentation {
  String get title;
  String get answerLabel;
  String get finishLabel;
  String get nextLabel;
  String get resultTitle;
  String resultMessage(int score, int total);
  List<PlacementQuestion> get questions;
}

/// One language-specific placement question displayed by the shared shell.
final class PlacementQuestion {
  final String prompt;
  final String answer;

  const PlacementQuestion({required this.prompt, required this.answer});
}
