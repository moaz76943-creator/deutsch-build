import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/user_vocabulary_service.dart';
import 'dart:io';
import 'package:path/path.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await UserVocabularyService.instance.close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_vocabulary.db');
    if (await File(path).exists()) {
      await databaseFactory.deleteDatabase(path);
    }
  });

  test('toggleFavorite adds and removes favorite', () async {
    final service = UserVocabularyService.instance;
    final repo = FavoritesRepository.instance;

    await service.database;

    expect(await repo.isFavorite('word1'), isFalse);
    expect(await repo.getFavorites(), isEmpty);

    await repo.toggleFavorite('word1');
    expect(await repo.isFavorite('word1'), isTrue);
    expect(await repo.getFavorites(), contains('word1'));

    await repo.toggleFavorite('word1');
    expect(await repo.isFavorite('word1'), isFalse);
    expect(await repo.getFavorites(), isEmpty);
  });

  test('addCustomEntry and getCustomEntries work', () async {
    final service = UserVocabularyService.instance;

    await service.database;

    final entry = {
      'id': 'custom_1',
      'german_text': 'Hund',
      'arabic_translation': 'كلب',
      'article': 'der',
      'notes': '',
      'example_sentence': 'Der Hund bellt.',
      'created_at': DateTime.now().toIso8601String(),
      'is_custom': 1,
    };

    await service.addCustomEntry(entry);

    final entries = await service.getCustomEntries();
    expect(entries.length, 1);
    expect(entries.first['german_text'], 'Hund');
    expect(entries.first['arabic_translation'], 'كلب');

    await service.deleteCustomEntry('custom_1');
    final emptyEntries = await service.getCustomEntries();
    expect(emptyEntries, isEmpty);
  });
}
