import 'dart:convert';

import 'deck_models.dart';
import 'deck_parser_contract.dart';
import 'deck_validation.dart';

/// Pure-Dart parser for the canonical language-matrix JSON schema.
///
/// Compatibility target: tools/data_generator/schema.json version 1.0.0.
/// Every accepted entry must match the explicit source -> target direction.
final class JsonDeckParser implements DeckParserContract {
  static const String supportedSchemaVersion = '1.0.0';

  static const Set<String> _cefrLevels = <String>{'A1', 'A2', 'B1', 'B2'};
  static const Set<String> _partsOfSpeech = <String>{
    'noun',
    'verb',
    'adjective',
    'adverb',
    'pronoun',
    'preposition',
    'conjunction',
    'interjection',
    'determiner',
    'numeral',
    'phrase',
    'other',
  };

  static const Set<String> _rootKeys = <String>{'schema_version', 'entries'};
  static const Set<String> _entryKeys = <String>{
    'canonical_key',
    'cefr_level',
    'source_text',
    'target_text',
    'pair_identity',
    'phonetics',
    'part_of_speech',
    'bidirectional_flag',
    'rtl_flag',
    'concept_id',
    'domain',
    'plural_form',
    'source_rtl',
    'target_rtl',
    'example_sentence',
  };
  static const Set<String> _pairKeys = <String>{
    'id',
    'source_language',
    'target_language',
    'source_direction',
    'target_direction',
    'record_id',
    'reverse_record_id',
  };
  static const Set<String> _phoneticKeys = <String>{'source', 'target'};
  static const Set<String> _exampleKeys = <String>{'source', 'target'};
  static const Set<String> _domains = <String>{
    'workplace_healthcare',
    'emergency',
    'bureaucracy_registration',
    'daily_essentials',
  };
  static final RegExp _canonicalKeyPattern = RegExp(
    r'^[A-Za-z0-9][A-Za-z0-9._:-]*$',
  );
  static final RegExp _languagePattern = RegExp(
    r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$',
  );

  @override
  ParsedDeck parse(
    String jsonText, {
    required String deckId,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    final errors = <DeckValidationError>[];

    final normalizedDeckId = deckId.trim();
    if (normalizedDeckId.isEmpty) {
      errors.add(
        const DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: r'$.deckId',
          message: 'deckId must not be empty',
        ),
      );
    }

    final expectedSource = _normalizeLanguage(
      sourceLanguage,
      r'$.sourceLanguage',
      errors,
    );
    final expectedTarget = _normalizeLanguage(
      targetLanguage,
      r'$.targetLanguage',
      errors,
    );

    if (expectedSource != null &&
        expectedTarget != null &&
        expectedSource == expectedTarget) {
      errors.add(
        const DeckValidationError(
          code: DeckValidationErrorCode.directionMismatch,
          path: r'$.pair',
          message: 'source and target languages must differ',
        ),
      );
    }

    Object? decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException catch (error) {
      throw DeckValidationException(<DeckValidationError>[
        DeckValidationError(
          code: DeckValidationErrorCode.invalidJson,
          path: r'$',
          message: 'invalid JSON: ${error.message}',
        ),
      ]);
    }

    final root = _stringMap(decoded);
    if (root == null) {
      errors.add(
        const DeckValidationError(
          code: DeckValidationErrorCode.invalidRoot,
          path: r'$',
          message: 'dataset root must be an object',
        ),
      );
      throw DeckValidationException(errors);
    }

    _rejectUnexpectedKeys(root, _rootKeys, r'$', errors);

    final version = _requiredString(
      root,
      'schema_version',
      r'$.schema_version',
      errors,
    );
    if (version != null && version != supportedSchemaVersion) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: r'$.schema_version',
          message:
              'expected schema version $supportedSchemaVersion, got $version',
        ),
      );
    }

    final entriesValue = root['entries'];
    if (!root.containsKey('entries')) {
      errors.add(
        const DeckValidationError(
          code: DeckValidationErrorCode.missingRequiredField,
          path: r'$.entries',
          message: 'required property missing',
        ),
      );
    } else if (entriesValue is! List) {
      errors.add(
        const DeckValidationError(
          code: DeckValidationErrorCode.invalidFieldType,
          path: r'$.entries',
          message: 'expected array',
        ),
      );
    } else if (entriesValue.isEmpty) {
      errors.add(
        const DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: r'$.entries',
          message: 'entries must contain at least one item',
        ),
      );
    }

    if (entriesValue is! List || entriesValue.isEmpty) {
      throw DeckValidationException(errors);
    }

    final cards = <VocabularyCard>[];
    String? deckLevel;

    for (var index = 0; index < entriesValue.length; index++) {
      final itemPath = r'$.entries[' + index.toString() + ']';
      final before = errors.length;
      final entry = _stringMap(entriesValue[index]);

      if (entry == null) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidFieldType,
            path: itemPath,
            message: 'entry must be an object',
          ),
        );
        continue;
      }

      _rejectUnexpectedKeys(entry, _entryKeys, itemPath, errors);

      final canonicalKey = _requiredString(
        entry,
        'canonical_key',
        '$itemPath.canonical_key',
        errors,
        nonEmpty: true,
      );
      if (canonicalKey != null &&
          !_canonicalKeyPattern.hasMatch(canonicalKey)) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidValue,
            path: '$itemPath.canonical_key',
            message: 'canonical key does not match matrix schema pattern',
          ),
        );
      }

      final cefrLevel = _requiredString(
        entry,
        'cefr_level',
        '$itemPath.cefr_level',
        errors,
        nonEmpty: true,
      );
      if (cefrLevel != null && !_cefrLevels.contains(cefrLevel)) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidValue,
            path: '$itemPath.cefr_level',
            message: 'unsupported CEFR level: $cefrLevel',
          ),
        );
      } else if (cefrLevel != null) {
        if (deckLevel == null) {
          deckLevel = cefrLevel;
        } else if (deckLevel != cefrLevel) {
          errors.add(
            DeckValidationError(
              code: DeckValidationErrorCode.inconsistentMetadata,
              path: '$itemPath.cefr_level',
              message: 'all entries in a deck must share one CEFR level',
            ),
          );
        }
      }

      final sourceText = _requiredString(
        entry,
        'source_text',
        '$itemPath.source_text',
        errors,
        nonEmpty: true,
      );
      final targetText = _requiredString(
        entry,
        'target_text',
        '$itemPath.target_text',
        errors,
        nonEmpty: true,
      );

      final partOfSpeech = _requiredString(
        entry,
        'part_of_speech',
        '$itemPath.part_of_speech',
        errors,
        nonEmpty: true,
      );
      if (partOfSpeech != null && !_partsOfSpeech.contains(partOfSpeech)) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidValue,
            path: '$itemPath.part_of_speech',
            message: 'unsupported part_of_speech: $partOfSpeech',
          ),
        );
      }

      _requiredBool(
        entry,
        'bidirectional_flag',
        '$itemPath.bidirectional_flag',
        errors,
      );
      _requiredBool(entry, 'rtl_flag', '$itemPath.rtl_flag', errors);

      _validateOptionalEntryFields(entry, itemPath, errors);

      final pair = _requiredMap(
        entry,
        'pair_identity',
        '$itemPath.pair_identity',
        errors,
      );
      final pairData = pair == null
          ? null
          : _validatePair(
              pair,
              '$itemPath.pair_identity',
              expectedSource,
              expectedTarget,
              errors,
            );

      final phonetics = _requiredMap(
        entry,
        'phonetics',
        '$itemPath.phonetics',
        errors,
      );
      String? sourcePhonetics;
      if (phonetics != null) {
        _rejectUnexpectedKeys(
          phonetics,
          _phoneticKeys,
          '$itemPath.phonetics',
          errors,
        );
        sourcePhonetics = _requiredString(
          phonetics,
          'source',
          '$itemPath.phonetics.source',
          errors,
        );
        _requiredString(
          phonetics,
          'target',
          '$itemPath.phonetics.target',
          errors,
        );
      }

      final exampleSentences = <ExampleSentence>[];
      if (entry.containsKey('example_sentence')) {
        final example = _stringMap(entry['example_sentence']);
        if (example == null) {
          errors.add(
            DeckValidationError(
              code: DeckValidationErrorCode.invalidFieldType,
              path: '$itemPath.example_sentence',
              message: 'expected object',
            ),
          );
        } else {
          _rejectUnexpectedKeys(
            example,
            _exampleKeys,
            '$itemPath.example_sentence',
            errors,
          );
          final exampleSource = _requiredString(
            example,
            'source',
            '$itemPath.example_sentence.source',
            errors,
            nonEmpty: true,
          );
          final exampleTarget = _requiredString(
            example,
            'target',
            '$itemPath.example_sentence.target',
            errors,
            nonEmpty: true,
          );
          if (exampleSource != null && exampleTarget != null) {
            exampleSentences.add(
              ExampleSentence(
                textSource: exampleSource,
                textTarget: exampleTarget,
                contextNote: null,
              ),
            );
          }
        }
      }

      if (errors.length == before &&
          canonicalKey != null &&
          sourceText != null &&
          targetText != null &&
          partOfSpeech != null &&
          sourcePhonetics != null &&
          pairData != null) {
        cards.add(
          VocabularyCard(
            id: canonicalKey,
            term: sourceText,
            transliteration: sourcePhonetics,
            partOfSpeech: partOfSpeech,
            definitions: Map<String, String>.unmodifiable(<String, String>{
              pairData.targetLanguage: targetText,
            }),
            exampleSentences: List<ExampleSentence>.unmodifiable(
              exampleSentences,
            ),
            audioMarker: null,
          ),
        );
      }
    }

    if (errors.isNotEmpty) {
      throw DeckValidationException(errors);
    }

    if (version == null ||
        deckLevel == null ||
        expectedSource == null ||
        expectedTarget == null) {
      throw DeckValidationException(<DeckValidationError>[
        const DeckValidationError(
          code: DeckValidationErrorCode.invalidRoot,
          path: r'$',
          message: 'deck metadata could not be derived',
        ),
      ]);
    }

    return ParsedDeck(
      metadata: DeckMetadata(
        deckId: normalizedDeckId,
        sourceLanguage: expectedSource,
        targetLanguage: expectedTarget,
        cefrLevel: deckLevel,
        version: version,
        totalCards: cards.length,
      ),
      cards: List<VocabularyCard>.unmodifiable(cards),
    );
  }

  void _validateOptionalEntryFields(
    Map<String, Object?> entry,
    String path,
    List<DeckValidationError> errors,
  ) {
    if (entry.containsKey('concept_id')) {
      final conceptId = _optionalNonEmptyString(
        entry,
        'concept_id',
        '$path.concept_id',
        errors,
      );
      if (conceptId != null && !_canonicalKeyPattern.hasMatch(conceptId)) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidValue,
            path: '$path.concept_id',
            message: 'concept_id does not match matrix schema pattern',
          ),
        );
      }
    }

    if (entry.containsKey('plural_form')) {
      _optionalNonEmptyString(
        entry,
        'plural_form',
        '$path.plural_form',
        errors,
      );
    }

    if (entry.containsKey('domain')) {
      final domain = _optionalNonEmptyString(
        entry,
        'domain',
        '$path.domain',
        errors,
      );
      if (domain != null && !_domains.contains(domain)) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidValue,
            path: '$path.domain',
            message: 'unsupported domain: $domain',
          ),
        );
      }
    }

    for (final key in <String>['source_rtl', 'target_rtl']) {
      if (entry.containsKey(key) && entry[key] is! bool) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidFieldType,
            path: '$path.$key',
            message: 'expected boolean',
          ),
        );
      }
    }
  }

  _PairData? _validatePair(
    Map<String, Object?> pair,
    String path,
    String? expectedSource,
    String? expectedTarget,
    List<DeckValidationError> errors,
  ) {
    final before = errors.length;
    _rejectUnexpectedKeys(pair, _pairKeys, path, errors);

    final id = _requiredString(pair, 'id', '$path.id', errors, nonEmpty: true);
    final source = _requiredString(
      pair,
      'source_language',
      '$path.source_language',
      errors,
      nonEmpty: true,
    );
    final target = _requiredString(
      pair,
      'target_language',
      '$path.target_language',
      errors,
      nonEmpty: true,
    );
    final sourceDirection = _requiredString(
      pair,
      'source_direction',
      '$path.source_direction',
      errors,
      nonEmpty: true,
    );
    final targetDirection = _requiredString(
      pair,
      'target_direction',
      '$path.target_direction',
      errors,
      nonEmpty: true,
    );

    for (final key in <String>['record_id', 'reverse_record_id']) {
      if (pair.containsKey(key)) {
        _optionalNonEmptyString(pair, key, '$path.$key', errors);
      }
    }

    if (source != null && !_languagePattern.hasMatch(source)) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: '$path.source_language',
          message: 'invalid language code',
        ),
      );
    }
    if (target != null && !_languagePattern.hasMatch(target)) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: '$path.target_language',
          message: 'invalid language code',
        ),
      );
    }

    if (source != null && target != null) {
      if (source == target) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.directionMismatch,
            path: path,
            message: 'source and target language must differ',
          ),
        );
      }

      if (expectedSource != null &&
          expectedTarget != null &&
          (source != expectedSource || target != expectedTarget)) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.directionMismatch,
            path: path,
            message:
                'expected directed pair $expectedSource->$expectedTarget, got $source->$target',
          ),
        );
      }

      final expectedId = '$source->$target';
      if (id != null && id != expectedId) {
        errors.add(
          DeckValidationError(
            code: DeckValidationErrorCode.invalidValue,
            path: '$path.id',
            message: 'expected directed pair id $expectedId',
          ),
        );
      }
    }

    if (sourceDirection != null &&
        sourceDirection != 'ltr' &&
        sourceDirection != 'rtl') {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: '$path.source_direction',
          message: 'direction must be ltr or rtl',
        ),
      );
    }
    if (targetDirection != null &&
        targetDirection != 'ltr' &&
        targetDirection != 'rtl') {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: '$path.target_direction',
          message: 'direction must be ltr or rtl',
        ),
      );
    }

    if (errors.length != before || source == null || target == null) {
      return null;
    }
    return _PairData(sourceLanguage: source, targetLanguage: target);
  }

  String? _normalizeLanguage(
    String value,
    String path,
    List<DeckValidationError> errors,
  ) {
    final normalized = value.trim().toLowerCase();
    if (!_languagePattern.hasMatch(normalized)) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: path,
          message: 'invalid language code: $value',
        ),
      );
      return null;
    }
    return normalized;
  }

  void _rejectUnexpectedKeys(
    Map<String, Object?> object,
    Set<String> allowed,
    String path,
    List<DeckValidationError> errors,
  ) {
    final unexpected =
        object.keys.where((key) => !allowed.contains(key)).toList()..sort();
    for (final key in unexpected) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: '$path.$key',
          message: 'unexpected property',
        ),
      );
    }
  }

  String? _requiredString(
    Map<String, Object?> object,
    String key,
    String path,
    List<DeckValidationError> errors, {
    bool nonEmpty = false,
  }) {
    if (!object.containsKey(key)) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.missingRequiredField,
          path: path,
          message: 'required property missing',
        ),
      );
      return null;
    }
    final value = object[key];
    if (value is! String) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidFieldType,
          path: path,
          message: 'expected string',
        ),
      );
      return null;
    }
    if (nonEmpty && value.isEmpty) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: path,
          message: 'string must not be empty',
        ),
      );
      return null;
    }
    return value;
  }

  String? _optionalNonEmptyString(
    Map<String, Object?> object,
    String key,
    String path,
    List<DeckValidationError> errors,
  ) {
    final value = object[key];
    if (value is! String) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidFieldType,
          path: path,
          message: 'expected string',
        ),
      );
      return null;
    }
    if (value.isEmpty) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidValue,
          path: path,
          message: 'string must not be empty',
        ),
      );
      return null;
    }
    return value;
  }

  bool? _requiredBool(
    Map<String, Object?> object,
    String key,
    String path,
    List<DeckValidationError> errors,
  ) {
    if (!object.containsKey(key)) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.missingRequiredField,
          path: path,
          message: 'required property missing',
        ),
      );
      return null;
    }
    final value = object[key];
    if (value is! bool) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidFieldType,
          path: path,
          message: 'expected boolean',
        ),
      );
      return null;
    }
    return value;
  }

  Map<String, Object?>? _requiredMap(
    Map<String, Object?> object,
    String key,
    String path,
    List<DeckValidationError> errors,
  ) {
    if (!object.containsKey(key)) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.missingRequiredField,
          path: path,
          message: 'required property missing',
        ),
      );
      return null;
    }
    final value = _stringMap(object[key]);
    if (value == null) {
      errors.add(
        DeckValidationError(
          code: DeckValidationErrorCode.invalidFieldType,
          path: path,
          message: 'expected object',
        ),
      );
    }
    return value;
  }

  Map<String, Object?>? _stringMap(Object? value) {
    if (value is! Map) {
      return null;
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        return null;
      }
      result[key] = entry.value;
    }
    return result;
  }
}

final class _PairData {
  const _PairData({required this.sourceLanguage, required this.targetLanguage});

  final String sourceLanguage;
  final String targetLanguage;
}
