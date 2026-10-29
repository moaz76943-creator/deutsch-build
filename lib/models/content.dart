import '../core/content_contract.dart';

class ContentItem implements LearningContent {
  final String id, german, arabic, sentence, sentenceAr, topic, skill;
  final String article, plural;
  final List<String> accepted;

  const ContentItem({
    required this.id,
    required this.german,
    required this.arabic,
    required this.sentence,
    required this.sentenceAr,
    required this.topic,
    required this.skill,
    this.article = '',
    this.plural = '',
    this.accepted = const [],
  });

  @override
  String get sourceText => german;

  @override
  String get translationText => arabic;

  @override
  String get exampleText => sentence;

  @override
  String get exampleTranslationText => sentenceAr;

  @override
  String get grammaticalMarker => article;

  @override
  String get pluralForm => plural;

  @override
  List<String> get acceptedForms => accepted;
}
