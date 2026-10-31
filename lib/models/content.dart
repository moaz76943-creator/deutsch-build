import 'package:deutsch_bilarabi/core/content_contract.dart';

class ContentItem implements LearningContent {
  @override
  final String id;
  final String german, arabic, sentence, sentenceAr;
  @override
  final String topic;
  @override
  final String skill;
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

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'sourceText': sourceText,
        'translationText': translationText,
        'exampleText': exampleText,
        'exampleTranslationText': exampleTranslationText,
        'topic': topic,
        'skill': skill,
        'grammaticalMarker': grammaticalMarker,
        'pluralForm': pluralForm,
        'acceptedForms': acceptedForms,
      };
}
