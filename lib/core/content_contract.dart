/// Language-neutral read-only view of learning content.
///
/// Shared read-only content contract used by language-neutral learning services.
/// Concrete language models implement this contract at the language boundary.
abstract interface class LearningContent {
  String get id;
  String get sourceText;
  String get translationText;
  String get exampleText;
  String get exampleTranslationText;
  String get topic;
  String get skill;
  String get grammaticalMarker;
  String get pluralForm;
  List<String> get acceptedForms;
}
