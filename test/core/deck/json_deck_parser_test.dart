import 'dart:convert';

import '../../../lib/core/deck/deck_parser_contract.dart';
import '../../../lib/core/deck/deck_validation.dart';
import '../../../lib/core/deck/json_deck_parser.dart';

void main() {
  _parsesCanonicalMatrixFixture();
  _collectsMissingAndMalformedItemErrors();
  _rejectsDirectionalLanguageMismatch();
  _preservesRtlAndLtrTextIntegrity();
  _usesSchemaDirectionTagsWithoutLanguageGuessing();
  _rejectsConceptIdThatViolatesSchemaPattern();
}

void _parsesCanonicalMatrixFixture() {
  final DeckParserContract parser = JsonDeckParser();
  final deck = parser.parse(
    _validFixture(
      sourceText: 'Hallo',
      targetText: 'مرحباً',
      sourcePhonetics: 'haˈloː',
      targetPhonetics: 'mar.ħa.ban',
      includeExample: true,
    ),
    deckId: 'de-ar-a1-core',
    sourceLanguage: 'de',
    targetLanguage: 'ar',
  );

  _expect(deck.metadata.deckId, 'de-ar-a1-core', 'deck id');
  _expect(deck.metadata.sourceLanguage, 'de', 'source language');
  _expect(deck.metadata.targetLanguage, 'ar', 'target language');
  _expect(deck.metadata.cefrLevel, 'A1', 'CEFR level');
  _expect(deck.metadata.version, '1.0.0', 'schema version');
  _expect(deck.metadata.totalCards, 1, 'card count');

  final card = deck.cards.single;
  _expect(
    card.id,
    'de-ar.a1.greeting.hallo.forward',
    'canonical key maps to id',
  );
  _expect(card.term, 'Hallo', 'source_text maps to term');
  _expect(
    card.transliteration,
    'haˈloː',
    'source phonetics map to transliteration',
  );
  _expect(card.partOfSpeech, 'interjection', 'part of speech');
  _expect(
    card.definitions['ar'],
    'مرحباً',
    'target text maps to target-language definition',
  );
  _expect(card.audioMarker, null, 'matrix schema has no audio marker field');

  final example = card.exampleSentences.single;
  _expect(example.textSource, 'Hallo zusammen!', 'example source');
  _expect(example.textTarget, 'مرحباً جميعاً!', 'example target');
  _expect(example.contextNote, null, 'matrix schema has no context note field');
}

void _collectsMissingAndMalformedItemErrors() {
  final parser = JsonDeckParser();

  _expectValidationException(
    () => parser.parse(
      jsonEncode(<String, Object?>{'schema_version': '1.0.0'}),
      deckId: 'broken-root',
      sourceLanguage: 'de',
      targetLanguage: 'ar',
    ),
    (error) {
      _expect(
        error.errors.any((item) => item.path == r'$.entries'),
        true,
        'missing entries key must be reported',
      );
    },
    'missing mandatory root key',
  );

  final malformed = jsonEncode(<String, Object?>{
    'schema_version': '1.0.0',
    'entries': <Object?>[
      <String, Object?>{
        'canonical_key': 'de-ar.a1.bad.one',
        'cefr_level': 'A1',
        'source_text': 'Hallo',
        'pair_identity': _pairIdentity('de', 'ar'),
        'phonetics': <String, String>{'source': 'haˈloː', 'target': ''},
        'part_of_speech': 'interjection',
        'bidirectional_flag': false,
        'rtl_flag': true,
      },
      <String, Object?>{
        'canonical_key': 'de-ar.a1.bad.two',
        'cefr_level': 'C9',
        'source_text': '',
        'target_text': 'نص',
        'pair_identity': <String, Object?>{
          ..._pairIdentity('de', 'ar'),
          'id': 'wrong-pair',
        },
        'phonetics': <String, Object?>{'source': 42, 'target': 'nass'},
        'part_of_speech': 'unknown-kind',
        'bidirectional_flag': false,
        'rtl_flag': true,
      },
    ],
  });

  _expectValidationException(
    () => parser.parse(
      malformed,
      deckId: 'broken-items',
      sourceLanguage: 'de',
      targetLanguage: 'ar',
    ),
    (error) {
      _expect(
        error.errors.length >= 5,
        true,
        'multiple item errors must be collected',
      );
      _expect(
        error.errors.any((item) => item.path.endsWith('.target_text')),
        true,
        'missing target_text must be reported',
      );
      _expect(
        error.errors.any((item) => item.path.endsWith('.cefr_level')),
        true,
        'invalid CEFR level must be reported',
      );
      _expect(
        error.errors.any((item) => item.path.endsWith('.pair_identity.id')),
        true,
        'invalid directed pair id must be reported',
      );
    },
    'malformed entries',
  );
}

void _rejectsDirectionalLanguageMismatch() {
  final parser = JsonDeckParser();
  final reverse = _validFixture(
    sourceLanguage: 'ar',
    targetLanguage: 'de',
    sourceText: 'مرحباً',
    targetText: 'Hallo',
    sourcePhonetics: 'mar.ħa.ban',
    targetPhonetics: 'haˈloː',
  );

  _expectValidationException(
    () => parser.parse(
      reverse,
      deckId: 'de-ar-a1-core',
      sourceLanguage: 'de',
      targetLanguage: 'ar',
    ),
    (error) {
      _expect(
        error.errors.any(
          (item) => item.code == DeckValidationErrorCode.directionMismatch,
        ),
        true,
        'reverse direction must be rejected explicitly',
      );
    },
    'direction mismatch',
  );
}

void _preservesRtlAndLtrTextIntegrity() {
  final parser = JsonDeckParser();
  const source = 'Grüße & Straße — 123';
  const target = 'تحيّات في الشارع — ١٢٣';

  final deck = parser.parse(
    _validFixture(
      sourceText: source,
      targetText: target,
      sourcePhonetics: 'ˈɡʁyːsə',
      targetPhonetics: 'ta.ħij.jaːt',
    ),
    deckId: 'de-ar-a1-unicode',
    sourceLanguage: 'de',
    targetLanguage: 'ar',
  );

  _expect(
    deck.cards.single.term,
    source,
    'LTR source text must round-trip exactly',
  );
  _expect(
    deck.cards.single.definitions['ar'],
    target,
    'RTL target text must round-trip exactly',
  );
}

void _usesSchemaDirectionTagsWithoutLanguageGuessing() {
  final parser = JsonDeckParser();
  const source = 'سڵاو';
  const target = 'hello';

  final fixture = jsonEncode(<String, Object?>{
    'schema_version': '1.0.0',
    'entries': <Object?>[
      <String, Object?>{
        'canonical_key': 'ku-en.a1.greeting.hello.forward',
        'cefr_level': 'A1',
        'source_text': source,
        'target_text': target,
        'pair_identity': <String, Object?>{
          'id': 'ku->en',
          'source_language': 'ku',
          'target_language': 'en',
          'source_direction': 'rtl',
          'target_direction': 'ltr',
        },
        'phonetics': <String, String>{'source': 'slaw', 'target': 'həˈloʊ'},
        'part_of_speech': 'interjection',
        'bidirectional_flag': false,
        'rtl_flag': true,
      },
    ],
  });

  final deck = parser.parse(
    fixture,
    deckId: 'ku-en-a1',
    sourceLanguage: 'ku',
    targetLanguage: 'en',
  );

  _expect(
    deck.cards.single.term,
    source,
    'schema-provided RTL source must parse',
  );
  _expect(
    deck.cards.single.definitions['en'],
    target,
    'schema-provided LTR target must parse',
  );
}

void _rejectsConceptIdThatViolatesSchemaPattern() {
  final parser = JsonDeckParser();
  final decoded = jsonDecode(
    _validFixture(
      sourceText: 'Hallo',
      targetText: 'مرحباً',
      sourcePhonetics: 'haˈloː',
      targetPhonetics: 'mar.ħa.ban',
    ),
  ) as Map<String, Object?>;
  final entries = decoded['entries'] as List<Object?>;
  final entry = entries.single as Map<String, Object?>;
  entry['concept_id'] = 'bad concept id';

  _expectValidationException(
    () => parser.parse(
      jsonEncode(decoded),
      deckId: 'de-ar-a1-core',
      sourceLanguage: 'de',
      targetLanguage: 'ar',
    ),
    (error) {
      _expect(
        error.errors.any(
          (item) =>
              item.code == DeckValidationErrorCode.invalidValue &&
              item.path.endsWith('.concept_id'),
        ),
        true,
        'concept_id outside schema pattern must be rejected',
      );
    },
    'invalid concept_id pattern',
  );
}

String _validFixture({
  String sourceLanguage = 'de',
  String targetLanguage = 'ar',
  required String sourceText,
  required String targetText,
  required String sourcePhonetics,
  required String targetPhonetics,
  bool includeExample = false,
}) {
  final entry = <String, Object?>{
    'canonical_key': 'de-ar.a1.greeting.hallo.forward',
    'cefr_level': 'A1',
    'source_text': sourceText,
    'target_text': targetText,
    'pair_identity': _pairIdentity(sourceLanguage, targetLanguage),
    'phonetics': <String, String>{
      'source': sourcePhonetics,
      'target': targetPhonetics,
    },
    'part_of_speech': 'interjection',
    'bidirectional_flag': false,
    'rtl_flag': sourceLanguage == 'ar' || targetLanguage == 'ar',
  };

  if (includeExample) {
    entry['example_sentence'] = <String, String>{
      'source': 'Hallo zusammen!',
      'target': 'مرحباً جميعاً!',
    };
  }

  return jsonEncode(<String, Object?>{
    'schema_version': '1.0.0',
    'entries': <Object?>[entry],
  });
}

Map<String, Object?> _pairIdentity(String source, String target) {
  return <String, Object?>{
    'id': '$source->$target',
    'source_language': source,
    'target_language': target,
    'source_direction': source == 'ar' ? 'rtl' : 'ltr',
    'target_direction': target == 'ar' ? 'rtl' : 'ltr',
  };
}

void _expectValidationException(
  void Function() action,
  void Function(DeckValidationException error) verify,
  String message,
) {
  try {
    action();
  } on DeckValidationException catch (error) {
    verify(error);
    return;
  }
  throw StateError('$message: expected DeckValidationException');
}

void _expect(Object? actual, Object? expected, String message) {
  if (actual != expected) {
    throw StateError('$message: expected $expected, got $actual');
  }
}
