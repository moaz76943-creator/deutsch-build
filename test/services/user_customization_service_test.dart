import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../lib/services/user_customization_service.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('UserCustomizationService', () {
    late UserCustomizationService service;

    setUp(() async {
      service = UserCustomizationService();
      // Clear db before each test
      final db = await service.db;
      await db.delete('user_vocab_customizations');
      await db.delete('user_custom_examples');
    });

    test('can save and retrieve translation override', () async {
      await service.saveTranslationOverride('word_1', 'custom_arabic_1', 'note_1');

      final customization = await service.getCustomization('word_1');
      expect(customization, isNotNull);
      expect(customization!.wordId, 'word_1');
      expect(customization.customArabicTranslation, 'custom_arabic_1');
      expect(customization.customNotes, 'note_1');
    });

    test('can update existing translation override', () async {
      await service.saveTranslationOverride('word_1', 'custom_arabic_1', 'note_1');
      await service.saveTranslationOverride('word_1', 'custom_arabic_2', 'note_2');

      final customization = await service.getCustomization('word_1');
      expect(customization, isNotNull);
      expect(customization!.wordId, 'word_1');
      expect(customization.customArabicTranslation, 'custom_arabic_2');
      expect(customization.customNotes, 'note_2');
    });

    test('can reset translation override', () async {
      await service.saveTranslationOverride('word_1', 'custom_arabic_1', 'note_1');
      await service.resetTranslationOverride('word_1');

      final customization = await service.getCustomization('word_1');
      expect(customization, isNull);
    });

    test('can add and retrieve custom examples', () async {
      await service.addCustomExample('word_1', 'german_1', 'arabic_1');
      await service.addCustomExample('word_1', 'german_2', 'arabic_2');

      final examples = await service.getCustomExamples('word_1');
      expect(examples.length, 2);
      expect(examples[0].germanSentence, 'german_1');
      expect(examples[0].arabicSentence, 'arabic_1');
      expect(examples[1].germanSentence, 'german_2');
      expect(examples[1].arabicSentence, 'arabic_2');
    });

    test('can delete custom examples', () async {
      await service.addCustomExample('word_1', 'german_1', 'arabic_1');
      var examples = await service.getCustomExamples('word_1');
      expect(examples.length, 1);

      await service.deleteCustomExample(examples[0].id);

      examples = await service.getCustomExamples('word_1');
      expect(examples.length, 0);
    });
  });
}
