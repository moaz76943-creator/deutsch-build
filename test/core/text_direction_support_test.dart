import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/language/app_text_direction.dart';
import 'package:deutsch_bilarabi/core/language/language_configuration.dart';
import 'package:deutsch_bilarabi/core/lexicon/vocabulary_entry.dart';

void main() {
  group('AppTextDirection', () {
    test('resolves Arabic as RTL and German/English as LTR', () {
      expect(AppTextDirection.forLanguage('ar'), AppTextDirection.rtl);
      expect(AppTextDirection.forLanguage('ar-JO'), AppTextDirection.rtl);
      expect(AppTextDirection.forLanguage('de'), AppTextDirection.ltr);
      expect(AppTextDirection.forLanguage('en'), AppTextDirection.ltr);
    });

    test('defaults unknown languages to LTR when metadata is unspecified', () {
      expect(AppTextDirection.forLanguage('zz'), AppTextDirection.ltr);
    });

    test('rejects malformed explicit direction values', () {
      expect(
        () => AppTextDirection.fromJson('auto', languageCode: 'ar'),
        throwsFormatException,
      );
    });
  });

  group('LanguageConfiguration', () {
    test('parses and serializes explicit direction flags', () {
      final config = LanguageConfiguration.fromJson(<String, Object?>{
        'sourceLanguage': 'de',
        'targetLanguage': 'ar',
        'sourceLanguageDirection': 'ltr',
        'targetLanguageDirection': 'rtl',
      });

      expect(config.sourceLanguage, 'de');
      expect(config.targetLanguage, 'ar');
      expect(config.sourceLanguageDirection, AppTextDirection.ltr);
      expect(config.targetLanguageDirection, AppTextDirection.rtl);
      expect(config.toJson(), <String, Object?>{
        'sourceLanguage': 'de',
        'targetLanguage': 'ar',
        'sourceLanguageDirection': 'ltr',
        'targetLanguageDirection': 'rtl',
      });
    });

    test('prefers generated direction metadata and falls back safely', () {
      final generated = LanguageConfiguration.fromJson(<String, Object?>{
        'pair_identity': <String, Object?>{
          'source_language': 'de',
          'target_language': 'ar',
          'source_direction': 'ltr',
          'target_direction': 'rtl',
        },
      });
      expect(generated.sourceLanguageDirection, AppTextDirection.ltr);
      expect(generated.targetLanguageDirection, AppTextDirection.rtl);

      final fallback = LanguageConfiguration.fromJson(<String, Object?>{
        'sourceLanguage': 'ar',
        'targetLanguage': 'en',
      });
      expect(fallback.sourceLanguageDirection, AppTextDirection.rtl);
      expect(fallback.targetLanguageDirection, AppTextDirection.ltr);
    });
  });

  group('VocabularyEntry JSON compatibility', () {
    test('round-trips lexicon-pipeline records with explicit directions', () {
      final json = <String, Object?>{
        'canonical_key': 'de-ar.a1.greeting.hallo.forward',
        'source_text': 'Hallo',
        'target_text': 'مرحباً',
        'pair_identity': <String, Object?>{
          'id': 'de->ar',
          'source_language': 'de',
          'target_language': 'ar',
          'source_direction': 'ltr',
          'target_direction': 'rtl',
        },
        'sourceLanguageDirection': 'ltr',
        'targetLanguageDirection': 'rtl',
        'partOfSpeech': 'interjection',
        'concept_id': 'de-ar.a1.greeting.hallo',
        'audioMarker': <String, Object?>{
          'source': 'audio/de/hallo.mp3',
          'target': 'audio/ar/marhaban.mp3',
        },
      };

      final entry = VocabularyEntry.fromJson(json);

      expect(entry.sourceLanguageDirection, AppTextDirection.ltr);
      expect(entry.targetLanguageDirection, AppTextDirection.rtl);
      expect(entry.toJson(), equals(json));
    });

    test('fallback does not mutate legacy record shape during round-trip', () {
      final json = <String, Object?>{
        'canonical_key': 'ar-en.a1.greeting.marhaban.forward',
        'source_text': 'مرحباً',
        'target_text': 'hello',
        'sourceLanguage': 'ar',
        'targetLanguage': 'en',
        'partOfSpeech': 'interjection',
      };

      final entry = VocabularyEntry.fromJson(json);

      expect(entry.sourceLanguageDirection, AppTextDirection.rtl);
      expect(entry.targetLanguageDirection, AppTextDirection.ltr);
      expect(entry.toJson(), equals(json));
      expect(
        entry.toJson(includeResolvedDirections: true),
        containsPair('sourceLanguageDirection', 'rtl'),
      );
      expect(
        entry.toJson(includeResolvedDirections: true),
        containsPair('targetLanguageDirection', 'ltr'),
      );
    });
  });
}
