import '../core/content_contract.dart';

/// Language-specific content quality contract.
///
/// The contract consumes the neutral learning-content projection so quality
/// rules can move with the selected language without coupling the core to a
/// concrete language or content model.
abstract interface class LanguageContentQuality {
  List<String> issues(LearningContent item);
  bool isLearnable(LearningContent item);
}
