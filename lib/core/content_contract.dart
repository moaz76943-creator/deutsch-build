// Universal Learning Content Contract
abstract class LearningContent {
  String get sourceText;
  String get translationText;
  String get exampleText;
  String get exampleTranslationText;
  String get grammaticalMarker;
  String get pluralForm;
  List<String> get acceptedForms;
  Map<String, dynamic> toMap();
}
