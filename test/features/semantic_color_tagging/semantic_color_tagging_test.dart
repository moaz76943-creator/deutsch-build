import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/features/semantic_color_tagging/semantic_color_tagging.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SemanticColorTagging', () {
    late SemanticColorTagging taggingService;

    setUp(() async {
      taggingService = SemanticColorTagging(
        factory: databaseFactory,
        path: inMemoryDatabasePath,
      );
    });

    tearDown(() async {
      await taggingService.close();
    });

    test('determines correct grammatical class', () {
      expect(taggingService.determineClass('der', 'Hund'), GrammaticalClass.masculineNoun);
      expect(taggingService.determineClass('die', 'Katze'), GrammaticalClass.feminineNoun);
      expect(taggingService.determineClass('das', 'Auto'), GrammaticalClass.neuterNoun);
      expect(taggingService.determineClass('', 'laufen'), GrammaticalClass.verb);
      expect(taggingService.determineClass('', 'schön'), GrammaticalClass.other);
    });

    test('tags and retrieves color for masculine noun', () async {
      await taggingService.tagAndSaveWord('1', 'Hund', 'der');
      final color = await taggingService.getColorForWord('1');
      expect(color, SemanticColorTagging.masculineColor);
    });

    test('tags and retrieves color for feminine noun', () async {
      await taggingService.tagAndSaveWord('2', 'Katze', 'die');
      final color = await taggingService.getColorForWord('2');
      expect(color, SemanticColorTagging.feminineColor);
    });

    test('tags and retrieves color for neuter noun', () async {
      await taggingService.tagAndSaveWord('3', 'Auto', 'das');
      final color = await taggingService.getColorForWord('3');
      expect(color, SemanticColorTagging.neuterColor);
    });

    test('tags and retrieves color for plural noun', () async {
      await taggingService.tagAndSaveWord('4', 'Kinder', 'die', isPlural: true);
      final color = await taggingService.getColorForWord('4');
      expect(color, SemanticColorTagging.pluralColor);
    });

    test('tags and retrieves color for verb', () async {
      await taggingService.tagAndSaveWord('5', 'laufen', '');
      final color = await taggingService.getColorForWord('5');
      expect(color, SemanticColorTagging.defaultColor);
    });
  });
}
