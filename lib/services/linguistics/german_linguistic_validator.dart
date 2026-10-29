import '../../data/canonical_grammar_catalog.dart';
import '../../models/grammar.dart';
import '../../models/linguistics/german_grammar_types.dart';
import '../../models/linguistics/german_noun.dart';
import '../../models/linguistics/german_verb.dart';
import '../../models/linguistics/linguistic_concept.dart';
import '../../models/linguistics/verb_valency_frame.dart';

enum LinguisticQaSeverity { error, warning }

final class LinguisticQaIssue {
  const LinguisticQaIssue({
    required this.code,
    required this.path,
    required this.message,
    this.severity = LinguisticQaSeverity.error,
  });

  final String code;
  final String path;
  final String message;
  final LinguisticQaSeverity severity;
}

final class LinguisticQaReport {
  LinguisticQaReport(Iterable<LinguisticQaIssue> issues)
      : issues = List<LinguisticQaIssue>.unmodifiable(issues);

  final List<LinguisticQaIssue> issues;

  List<LinguisticQaIssue> get errors => issues
      .where((issue) => issue.severity == LinguisticQaSeverity.error)
      .toList(growable: false);

  List<LinguisticQaIssue> get warnings => issues
      .where((issue) => issue.severity == LinguisticQaSeverity.warning)
      .toList(growable: false);

  bool get isValid => errors.isEmpty;

  void throwIfInvalid({String context = 'German linguistic QA'}) {
    if (isValid) return;
    final first = errors.first;
    throw LinguisticQaException(
      context + ': ' + first.code + ' at ' + first.path + ': ' + first.message,
    );
  }
}

final class LinguisticQaException implements Exception {
  const LinguisticQaException(this.message);

  final String message;

  @override
  String toString() => 'LinguisticQaException: ' + message;
}

/// Deterministic structural/semantic QA for canonical German data.
///
/// This validator deliberately avoids heuristic claims that are not universal
/// German rules. It validates relationships explicitly represented by the
/// canonical schema and reports incomplete metadata separately.
final class GermanLinguisticValidator {
  const GermanLinguisticValidator();

  LinguisticQaReport validateNoun(GermanNoun noun) {
    final issues = <LinguisticQaIssue>[];
    _validateConcept(
      noun.concept,
      expectedPartOfSpeech: LinguisticPartOfSpeech.noun,
      path: 'noun.' + noun.concept.id,
      issues: issues,
    );

    if (noun.gender == GermanGender.unknown ||
        noun.gender == GermanGender.none) {
      issues.add(
        LinguisticQaIssue(
          code: 'noun.gender_unresolved',
          path: 'noun.' + noun.concept.id + '.gender',
          message: 'Canonical German noun requires an explicit gender.',
        ),
      );
    }
    if (noun.declensionClass == GermanNounDeclensionClass.unknown) {
      issues.add(
        LinguisticQaIssue(
          code: 'noun.declension_unresolved',
          path: 'noun.' + noun.concept.id + '.declensionClass',
          message: 'Canonical German noun requires a declension class.',
        ),
      );
    }

    final forms = noun.caseForms;
    final singular = <String, String>{
      'nominativeSingular': forms.nominativeSingular,
      'accusativeSingular': forms.accusativeSingular,
      'dativeSingular': forms.dativeSingular,
      'genitiveSingular': forms.genitiveSingular,
    };
    for (final entry in singular.entries) {
      _requireText(
        entry.value,
        'noun.' + noun.concept.id + '.caseForms.' + entry.key,
        'noun.case_form_blank',
        issues,
      );
    }

    if (forms.nominativeSingular.trim() != noun.concept.lemma.trim()) {
      issues.add(
        LinguisticQaIssue(
          code: 'noun.lemma_nominative_mismatch',
          path: 'noun.' + noun.concept.id + '.caseForms.nominativeSingular',
          message: 'Lemma must equal nominative singular in this schema.',
        ),
      );
    }

    final pluralForms = <String, String?>{
      'nominativePlural': forms.nominativePlural,
      'accusativePlural': forms.accusativePlural,
      'dativePlural': forms.dativePlural,
      'genitivePlural': forms.genitivePlural,
    };
    final plural = _clean(noun.plural);
    if (plural == null) {
      if (pluralForms.values.any((value) => _clean(value) != null)) {
        issues.add(
          LinguisticQaIssue(
            code: 'noun.plural_forms_without_plural',
            path: 'noun.' + noun.concept.id + '.caseForms',
            message: 'Plural case forms require an explicit canonical plural.',
          ),
        );
      }
    } else {
      if (_clean(forms.nominativePlural) != plural) {
        issues.add(
          LinguisticQaIssue(
            code: 'noun.plural_mismatch',
            path: 'noun.' + noun.concept.id + '.caseForms.nominativePlural',
            message: 'Canonical plural must equal nominative plural.',
          ),
        );
      }
      for (final entry in pluralForms.entries) {
        if (_clean(entry.value) == null) {
          issues.add(
            LinguisticQaIssue(
              code: 'noun.plural_case_missing',
              path: 'noun.' + noun.concept.id + '.caseForms.' + entry.key,
              message: 'Declared plural requires all plural case forms.',
            ),
          );
        }
      }
    }

    return LinguisticQaReport(issues);
  }

  LinguisticQaReport validateVerb(GermanVerb verb) {
    final issues = <LinguisticQaIssue>[];
    _validateConcept(
      verb.concept,
      expectedPartOfSpeech: LinguisticPartOfSpeech.verb,
      path: 'verb.' + verb.concept.id,
      issues: issues,
    );

    _requireText(
      verb.infinitive,
      'verb.' + verb.concept.id + '.infinitive',
      'verb.infinitive_blank',
      issues,
    );
    if (verb.infinitive.trim() != verb.concept.lemma.trim()) {
      issues.add(
        LinguisticQaIssue(
          code: 'verb.lemma_infinitive_mismatch',
          path: 'verb.' + verb.concept.id + '.infinitive',
          message: 'Verb lemma must equal canonical infinitive.',
        ),
      );
    }
    if (verb.auxiliary == GermanAuxiliary.unknown) {
      issues.add(
        LinguisticQaIssue(
          code: 'verb.auxiliary_unresolved',
          path: 'verb.' + verb.concept.id + '.auxiliary',
          message: 'Canonical verb requires haben/sein classification.',
        ),
      );
    }
    if (verb.reflexivity == GermanReflexivity.unknown) {
      issues.add(
        LinguisticQaIssue(
          code: 'verb.reflexivity_unresolved',
          path: 'verb.' + verb.concept.id + '.reflexivity',
          message: 'Canonical verb requires explicit reflexivity metadata.',
        ),
      );
    }

    final separable = _clean(verb.separablePrefix);
    final inseparable = _clean(verb.inseparablePrefix);
    if (separable != null && inseparable != null) {
      issues.add(
        LinguisticQaIssue(
          code: 'verb.prefix_conflict',
          path: 'verb.' + verb.concept.id,
          message: 'Verb cannot declare separable and inseparable prefixes.',
        ),
      );
    }
    if (separable != null && !verb.infinitive.startsWith(separable)) {
      issues.add(
        LinguisticQaIssue(
          code: 'verb.separable_prefix_mismatch',
          path: 'verb.' + verb.concept.id + '.separablePrefix',
          message: 'Separable prefix must be a prefix of the infinitive.',
        ),
      );
    }
    if (inseparable != null && !verb.infinitive.startsWith(inseparable)) {
      issues.add(
        LinguisticQaIssue(
          code: 'verb.inseparable_prefix_mismatch',
          path: 'verb.' + verb.concept.id + '.inseparablePrefix',
          message: 'Inseparable prefix must be a prefix of the infinitive.',
        ),
      );
    }

    final frameIds = <String>{};
    for (final frame in verb.valencyFrames) {
      _validateValency(
        frame,
        'verb.' + verb.concept.id + '.valency.' + frame.frameId,
        issues,
      );
      if (!frameIds.add(frame.frameId.trim())) {
        issues.add(
          LinguisticQaIssue(
            code: 'valency.duplicate_frame_id',
            path: 'verb.' + verb.concept.id + '.valency',
            message: 'Valency frame IDs must be unique per verb.',
          ),
        );
      }
    }

    final formKeys = <String>{};
    for (final form in verb.forms) {
      _requireText(
        form.tense,
        'verb.' + verb.concept.id + '.forms.tense',
        'verb.form_field_blank',
        issues,
      );
      _requireText(
        form.personKey,
        'verb.' + verb.concept.id + '.forms.personKey',
        'verb.form_field_blank',
        issues,
      );
      _requireText(
        form.form,
        'verb.' + verb.concept.id + '.forms.form',
        'verb.form_field_blank',
        issues,
      );
      final key = form.tense.trim() + '|' + form.personKey.trim();
      if (!formKeys.add(key)) {
        issues.add(
          LinguisticQaIssue(
            code: 'verb.duplicate_form_key',
            path: 'verb.' + verb.concept.id + '.forms',
            message: 'Verb tense/person keys must be unique.',
          ),
        );
      }
    }

    return LinguisticQaReport(issues);
  }

  LinguisticQaReport validateGrammarCatalog(Iterable<GrammarTopic> topics) {
    final issues = <LinguisticQaIssue>[];
    final topicIds = <String>{};
    final ruleIds = <String>{};
    final quizIds = <String>{};
    const levels = <String>{'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

    for (final topic in topics) {
      final path = 'grammar.' + topic.id;
      if (!topicIds.add(topic.id.trim())) {
        issues.add(
          LinguisticQaIssue(
            code: 'grammar.duplicate_topic_id',
            path: path,
            message: 'Grammar topic IDs must be globally unique.',
          ),
        );
      }
      if (!levels.contains(topic.level)) {
        issues.add(
          LinguisticQaIssue(
            code: 'grammar.invalid_level',
            path: path + '.level',
            message: 'Grammar topic level must be A1 through C2.',
          ),
        );
      }
      _requireText(topic.id, path + '.id', 'grammar.blank_field', issues);
      _requireText(
        topic.titleDe,
        path + '.titleDe',
        'grammar.blank_field',
        issues,
      );
      _requireText(
        topic.titleAr,
        path + '.titleAr',
        'grammar.blank_field',
        issues,
      );
      _requireText(
        topic.summaryAr,
        path + '.summaryAr',
        'grammar.blank_field',
        issues,
      );

      if (topic.rules.isEmpty) {
        issues.add(
          LinguisticQaIssue(
            code: 'grammar.topic_without_rules',
            path: path + '.rules',
            message:
                'Canonical grammar topic should include at least one rule.',
            severity: LinguisticQaSeverity.warning,
          ),
        );
      }
      for (final rule in topic.rules) {
        final rulePath = path + '.rules.' + rule.id;
        if (!ruleIds.add(rule.id.trim())) {
          issues.add(
            LinguisticQaIssue(
              code: 'grammar.duplicate_rule_id',
              path: rulePath,
              message: 'Grammar rule IDs must be globally unique.',
            ),
          );
        }
        _requireText(rule.id, rulePath + '.id', 'grammar.blank_field', issues);
        _requireText(
          rule.title,
          rulePath + '.title',
          'grammar.blank_field',
          issues,
        );
        _requireText(
          rule.explanationAr,
          rulePath + '.explanationAr',
          'grammar.blank_field',
          issues,
        );
        for (var rowIndex = 0; rowIndex < rule.table.length; rowIndex++) {
          final row = rule.table[rowIndex];
          if (row.isEmpty || row.any((cell) => cell.trim().isEmpty)) {
            issues.add(
              LinguisticQaIssue(
                code: 'grammar.table_blank_cell',
                path: rulePath + '.table.' + rowIndex.toString(),
                message: 'Grammar table rows cannot contain blank cells.',
              ),
            );
          }
        }
        for (var exampleIndex = 0;
            exampleIndex < rule.examples.length;
            exampleIndex++) {
          final example = rule.examples[exampleIndex];
          _requireText(
            example.german,
            rulePath + '.examples.' + exampleIndex.toString() + '.german',
            'grammar.example_blank',
            issues,
          );
          _requireText(
            example.arabic,
            rulePath + '.examples.' + exampleIndex.toString() + '.arabic',
            'grammar.example_blank',
            issues,
          );
        }
      }

      for (final quiz in topic.miniChecks) {
        final quizPath = path + '.quiz.' + quiz.id;
        if (!quizIds.add(quiz.id.trim())) {
          issues.add(
            LinguisticQaIssue(
              code: 'grammar.duplicate_quiz_id',
              path: quizPath,
              message: 'Grammar quiz IDs must be globally unique.',
            ),
          );
        }
        _requireText(quiz.id, quizPath + '.id', 'grammar.blank_field', issues);
        _requireText(
          quiz.questionText,
          quizPath + '.questionText',
          'grammar.blank_field',
          issues,
        );
        _requireText(
          quiz.explanationAr,
          quizPath + '.explanationAr',
          'grammar.blank_field',
          issues,
        );
        if (quiz.options.length < 2) {
          issues.add(
            LinguisticQaIssue(
              code: 'grammar.quiz_too_few_options',
              path: quizPath + '.options',
              message: 'Grammar quiz requires at least two options.',
            ),
          );
        }
        if (quiz.correctAnswerIndex < 0 ||
            quiz.correctAnswerIndex >= quiz.options.length) {
          issues.add(
            LinguisticQaIssue(
              code: 'grammar.quiz_index_out_of_range',
              path: quizPath + '.correctAnswerIndex',
              message: 'Correct answer index must reference an option.',
            ),
          );
        }
        final normalizedOptions =
            quiz.options.map((option) => option.trim()).toList(growable: false);
        if (normalizedOptions.any((option) => option.isEmpty)) {
          issues.add(
            LinguisticQaIssue(
              code: 'grammar.quiz_blank_option',
              path: quizPath + '.options',
              message: 'Grammar quiz options cannot be blank.',
            ),
          );
        }
        if (normalizedOptions.toSet().length != normalizedOptions.length) {
          issues.add(
            LinguisticQaIssue(
              code: 'grammar.quiz_duplicate_option',
              path: quizPath + '.options',
              message: 'Grammar quiz options must be distinct.',
            ),
          );
        }
      }
    }

    return LinguisticQaReport(issues);
  }

  LinguisticQaReport validateCanonicalGrammar() =>
      validateGrammarCatalog(CanonicalGrammarCatalog.allTopics);

  void _validateConcept(
    LinguisticConcept concept, {
    required LinguisticPartOfSpeech expectedPartOfSpeech,
    required String path,
    required List<LinguisticQaIssue> issues,
  }) {
    _requireText(concept.id, path + '.id', 'concept.blank_id', issues);
    _requireText(
      concept.senseId,
      path + '.senseId',
      'concept.blank_sense_id',
      issues,
    );
    _requireText(concept.lemma, path + '.lemma', 'concept.blank_lemma', issues);
    if (concept.partOfSpeech != expectedPartOfSpeech) {
      issues.add(
        LinguisticQaIssue(
          code: 'concept.part_of_speech_mismatch',
          path: path + '.partOfSpeech',
          message: 'Concept part of speech does not match German model.',
        ),
      );
    }
    if (concept.semanticTags.map((tag) => tag.trim()).toSet().length !=
        concept.semanticTags.length) {
      issues.add(
        LinguisticQaIssue(
          code: 'concept.duplicate_semantic_tag',
          path: path + '.semanticTags',
          message: 'Semantic tags must be unique.',
        ),
      );
    }
    if (concept.cefr == CefrLevel.unknown) {
      issues.add(
        LinguisticQaIssue(
          code: 'concept.cefr_unresolved',
          path: path + '.cefr',
          message: 'CEFR is not resolved yet.',
          severity: LinguisticQaSeverity.warning,
        ),
      );
    }
    if (concept.register == LanguageRegister.unknown) {
      issues.add(
        LinguisticQaIssue(
          code: 'concept.register_unresolved',
          path: path + '.register',
          message: 'Register is not resolved yet.',
          severity: LinguisticQaSeverity.warning,
        ),
      );
    }
  }

  void _validateValency(
    VerbValencyFrame frame,
    String path,
    List<LinguisticQaIssue> issues,
  ) {
    _requireText(
      frame.frameId,
      path + '.frameId',
      'valency.blank_frame_id',
      issues,
    );
    _requireText(
      frame.semanticRole,
      path + '.semanticRole',
      'valency.blank_semantic_role',
      issues,
    );
    final preposition = _clean(frame.preposition);
    final hasPrepositionCase = frame.prepositionCase != null;
    if ((preposition == null) != (!hasPrepositionCase)) {
      issues.add(
        LinguisticQaIssue(
          code: 'valency.preposition_case_pair',
          path: path,
          message:
              'Preposition and preposition case must be declared together.',
        ),
      );
    }
    if (frame.governedCase == null &&
        !(preposition != null && hasPrepositionCase)) {
      issues.add(
        LinguisticQaIssue(
          code: 'valency.missing_government',
          path: path,
          message: 'Valency frame requires case or preposition government.',
        ),
      );
    }
  }

  void _requireText(
    String value,
    String path,
    String code,
    List<LinguisticQaIssue> issues,
  ) {
    if (value.trim().isEmpty) {
      issues.add(
        LinguisticQaIssue(
          code: code,
          path: path,
          message: 'Required canonical text is blank.',
        ),
      );
    }
  }

  String? _clean(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }
}
