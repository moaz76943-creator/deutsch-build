import 'pair_mechanics.dart';

enum GoldCaseLifecycle { candidate, canonical }

final class ArabicGermanGoldCase {
  final String caseId;
  final String semanticIntentId;
  final String sourceText;
  final String canonicalTargetText;
  final List<String> acceptedTargetForms;
  final String skill;
  final String level;
  final List<String> provenanceRefs;
  final List<String> evidenceRefs;
  final GoldCaseLifecycle lifecycle;
  final String contrastiveNotes;

  ArabicGermanGoldCase({
    required this.caseId,
    required this.semanticIntentId,
    required this.sourceText,
    required this.canonicalTargetText,
    required List<String> acceptedTargetForms,
    required this.skill,
    required this.level,
    required List<String> provenanceRefs,
    required List<String> evidenceRefs,
    required this.lifecycle,
    this.contrastiveNotes = '',
  })  : acceptedTargetForms = List<String>.unmodifiable(acceptedTargetForms),
        provenanceRefs = List<String>.unmodifiable(provenanceRefs),
        evidenceRefs = List<String>.unmodifiable(evidenceRefs);

  PairIdentity get pair => ArabicGermanGoldStandard.pair;
}

abstract final class ArabicGermanGoldStandard {
  static const int maxTextLength = 500;
  static const int maxIdentifierLength = 160;
  static const int maxAcceptedForms = 16;
  static const int maxReferenceCount = 32;
  static const int maxReferenceLength = 240;

  static final PairIdentity pair = PairIdentity(
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
  );

  static List<String> validate(ArabicGermanGoldCase value) {
    final errors = <String>[];

    _validateRequiredIdentifier(errors, 'caseId', value.caseId);
    _validateRequiredIdentifier(
      errors,
      'semanticIntentId',
      value.semanticIntentId,
    );
    _validateRequiredIdentifier(errors, 'skill', value.skill);
    _validateRequiredIdentifier(errors, 'level', value.level);
    _validateRequiredText(errors, 'sourceText', value.sourceText);
    _validateRequiredText(
      errors,
      'canonicalTargetText',
      value.canonicalTargetText,
    );

    if (value.acceptedTargetForms.length > maxAcceptedForms) {
      errors.add('acceptedTargetForms');
    }
    for (final form in value.acceptedTargetForms) {
      if (form.trim().isEmpty || form.length > maxTextLength) {
        if (!errors.contains('acceptedTargetForms')) {
          errors.add('acceptedTargetForms');
        }
        break;
      }
    }

    _validateRefs(errors, 'provenanceRefs', value.provenanceRefs);
    _validateRefs(errors, 'evidenceRefs', value.evidenceRefs);

    if (value.contrastiveNotes.length > maxTextLength) {
      errors.add('contrastiveNotes');
    }

    return List<String>.unmodifiable(errors);
  }

  static bool countsTowardReadiness(ArabicGermanGoldCase value) {
    return value.lifecycle == GoldCaseLifecycle.canonical &&
        validate(value).isEmpty;
  }

  static void _validateRequiredIdentifier(
    List<String> errors,
    String field,
    String value,
  ) {
    if (value.trim().isEmpty || value.length > maxIdentifierLength) {
      errors.add(field);
    }
  }

  static void _validateRequiredText(
    List<String> errors,
    String field,
    String value,
  ) {
    if (value.trim().isEmpty || value.length > maxTextLength) {
      errors.add(field);
    }
  }

  static void _validateRefs(
    List<String> errors,
    String field,
    List<String> refs,
  ) {
    if (refs.isEmpty || refs.length > maxReferenceCount) {
      errors.add(field);
      return;
    }
    if (refs.any(
      (ref) => ref.trim().isEmpty || ref.length > maxReferenceLength,
    )) {
      errors.add(field);
    }
  }
}

extension BoundedFixtureStringRepeat on String {
  String operator *(int count) {
    if (count <= 0) return '';
    return List<String>.filled(count, this, growable: false).join();
  }
}
