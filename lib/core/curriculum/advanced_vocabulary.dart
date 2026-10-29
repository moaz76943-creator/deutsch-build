import '../content_contract.dart';

enum CefrLevel {
  a1,
  a2,
  b1,
  b2,
  c1,
  c2,
}

extension CefrLevelCode on CefrLevel {
  String get code => name.toUpperCase();
}

enum VocabularyPartOfSpeech {
  noun,
  verb,
  adjective,
  adverb,
  phrase,
  preposition,
  conjunction,
  other,
}

enum GermanArticle {
  der,
  die,
  das,
  plural,
  none,
}

extension GermanArticleText on GermanArticle {
  String get text => switch (this) {
        GermanArticle.der => 'der',
        GermanArticle.die => 'die',
        GermanArticle.das => 'das',
        GermanArticle.plural => 'Plural',
        GermanArticle.none => '',
      };
}

enum PerfectAuxiliary {
  haben,
  sein,
}

extension PerfectAuxiliaryText on PerfectAuxiliary {
  String get thirdPerson => switch (this) {
        PerfectAuxiliary.haben => 'hat',
        PerfectAuxiliary.sein => 'ist',
      };
}

final class PronunciationData {
  const PronunciationData({
    this.ipa = '',
    this.stressHint = '',
    this.audioKey = '',
  });

  final String ipa;
  final String stressHint;
  final String audioKey;
}

final class VerbMorphology {
  const VerbMorphology({
    required this.thirdPersonPresent,
    required this.preterite,
    required this.perfectAuxiliary,
    required this.pastParticiple,
    required this.separable,
    this.governedCase = '',
    this.preposition = '',
  });

  final String thirdPersonPresent;
  final String preterite;
  final PerfectAuxiliary perfectAuxiliary;
  final String pastParticiple;
  final bool separable;
  final String governedCase;
  final String preposition;

  String get perfectDisplay =>
      '${perfectAuxiliary.thirdPerson} $pastParticiple';
}

final class VocabularyFlashcardProjection {
  const VocabularyFlashcardProjection({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.frontLanguageCode,
    required this.backLanguageCode,
    required this.article,
    required this.frontSupportingText,
    required this.backSupportingText,
    required this.semanticLabel,
  });

  final String id;
  final String frontText;
  final String backText;
  final String frontLanguageCode;
  final String backLanguageCode;
  final String? article;
  final String? frontSupportingText;
  final String? backSupportingText;
  final String? semanticLabel;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'frontText': frontText,
        'backText': backText,
        'frontLanguageCode': frontLanguageCode,
        'backLanguageCode': backLanguageCode,
        'article': article,
        'frontSupportingText': frontSupportingText,
        'backSupportingText': backSupportingText,
        'semanticLabel': semanticLabel,
      };
}

final class AdvancedVocabularyEntry implements LearningContent {
  AdvancedVocabularyEntry({
    required this.id,
    required this.sourceText,
    required this.translationText,
    required this.exampleText,
    required this.exampleTranslationText,
    required this.topic,
    required this.skill,
    required this.level,
    required this.partOfSpeech,
    required this.grammaticalMarker,
    required List<String> acceptedForms,
    this.article = GermanArticle.none,
    this.pluralForm = '',
    this.pronunciation = const PronunciationData(),
    this.verbData,
    Set<String> tags = const <String>{},
    this.sourceLanguageCode = 'de',
    this.targetLanguageCode = 'ar',
  })  : acceptedForms = List<String>.unmodifiable(
          _deduplicateVisible(acceptedForms),
        ),
        tags = Set<String>.unmodifiable(
          tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty),
        ) {
    _requireVisible(id, 'id');
    _requireVisible(sourceText, 'sourceText');
    _requireVisible(translationText, 'translationText');
    _requireVisible(exampleText, 'exampleText');
    _requireVisible(exampleTranslationText, 'exampleTranslationText');
    _requireVisible(topic, 'topic');
    _requireVisible(skill, 'skill');
    _requireVisible(sourceLanguageCode, 'sourceLanguageCode');
    _requireVisible(targetLanguageCode, 'targetLanguageCode');

    if (partOfSpeech == VocabularyPartOfSpeech.noun &&
        article == GermanArticle.none) {
      throw ArgumentError(
        'German noun entries must define an article or plural marker.',
      );
    }
    if (partOfSpeech == VocabularyPartOfSpeech.verb && verbData == null) {
      throw ArgumentError('Verb entries must define VerbMorphology.');
    }
    if (this.acceptedForms.isEmpty) {
      throw ArgumentError('acceptedForms must contain at least one form.');
    }
  }

  @override
  final String id;

  @override
  final String sourceText;

  @override
  final String translationText;

  @override
  final String exampleText;

  @override
  final String exampleTranslationText;

  @override
  final String topic;

  @override
  final String skill;

  final CefrLevel level;
  final VocabularyPartOfSpeech partOfSpeech;
  final GermanArticle article;

  @override
  final String grammaticalMarker;

  @override
  final String pluralForm;

  @override
  final List<String> acceptedForms;

  final PronunciationData pronunciation;
  final VerbMorphology? verbData;
  final Set<String> tags;
  final String sourceLanguageCode;
  final String targetLanguageCode;

  String get articleText => article.text;

  LearningContent toLearningContent() => this;

  VocabularyFlashcardProjection get flashcard {
    final supportingFront = <String>[
      if (pronunciation.ipa.trim().isNotEmpty) pronunciation.ipa.trim(),
      if (partOfSpeech == VocabularyPartOfSpeech.verb && verbData != null)
        verbData!.perfectDisplay,
      if (pluralForm.trim().isNotEmpty) 'Plural: ${pluralForm.trim()}',
    ].join(' • ');

    return VocabularyFlashcardProjection(
      id: id,
      frontText: sourceText,
      backText: translationText,
      frontLanguageCode: sourceLanguageCode,
      backLanguageCode: targetLanguageCode,
      article: article == GermanArticle.none ? null : articleText,
      frontSupportingText:
          supportingFront.isEmpty ? exampleText : supportingFront,
      backSupportingText: exampleTranslationText,
      semanticLabel:
          '${level.code} ${partOfSpeech.name}: $sourceText — $translationText',
    );
  }

  bool accepts(String candidate) {
    final normalized = _normalize(candidate);
    return acceptedForms.any((form) => _normalize(form) == normalized);
  }
}

final class AdvancedVocabularyBank {
  AdvancedVocabularyBank({
    required this.id,
    required List<AdvancedVocabularyEntry> entries,
  }) : entries = List<AdvancedVocabularyEntry>.unmodifiable(entries) {
    _requireVisible(id, 'id');
    if (this.entries.isEmpty) {
      throw ArgumentError('Vocabulary bank must contain at least one entry.');
    }
    final ids = <String>{};
    for (final entry in this.entries) {
      if (!ids.add(entry.id)) {
        throw ArgumentError('Duplicate vocabulary entry id: ${entry.id}');
      }
    }
    _byId = <String, AdvancedVocabularyEntry>{
      for (final entry in this.entries) entry.id: entry,
    };
  }

  final String id;
  final List<AdvancedVocabularyEntry> entries;
  late final Map<String, AdvancedVocabularyEntry> _byId;

  AdvancedVocabularyEntry byId(String entryId) {
    final entry = _byId[entryId];
    if (entry == null) {
      throw ArgumentError.value(entryId, 'entryId', 'Unknown vocabulary id.');
    }
    return entry;
  }

  List<LearningContent> get learningContent =>
      List<LearningContent>.unmodifiable(entries);

  List<VocabularyFlashcardProjection> get flashcards =>
      List<VocabularyFlashcardProjection>.unmodifiable(
        entries.map((entry) => entry.flashcard),
      );

  List<AdvancedVocabularyEntry> forLevel(CefrLevel level) =>
      List<AdvancedVocabularyEntry>.unmodifiable(
        entries.where((entry) => entry.level == level),
      );

  List<AdvancedVocabularyEntry> forTopic(String topic) {
    final normalized = topic.trim().toLowerCase();
    return List<AdvancedVocabularyEntry>.unmodifiable(
      entries.where(
        (entry) => entry.topic.trim().toLowerCase() == normalized,
      ),
    );
  }

  List<AdvancedVocabularyEntry> forPartOfSpeech(
    VocabularyPartOfSpeech partOfSpeech,
  ) =>
      List<AdvancedVocabularyEntry>.unmodifiable(
        entries.where((entry) => entry.partOfSpeech == partOfSpeech),
      );
}

List<String> _deduplicateVisible(Iterable<String> values) {
  final seen = <String>{};
  final output = <String>[];
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) continue;
    final key = _normalize(trimmed);
    if (seen.add(key)) output.add(trimmed);
  }
  return output;
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

void _requireVisible(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, '$field must not be empty.');
  }
}
