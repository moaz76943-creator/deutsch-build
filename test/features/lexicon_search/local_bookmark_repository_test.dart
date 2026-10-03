import 'package:deutsch_bilarabi/core/infrastructure/storage/local_storage_repository.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/data/local_bookmark_repository.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/domain/lexicon_models.dart';
import 'package:flutter_test/flutter_test.dart';

final class _MemoryStorage implements LocalStorageRepository {
  final Map<StorageBucket, Map<String, Object?>> values =
      <StorageBucket, Map<String, Object?>>{};

  @override
  Future<void> save(StorageBucket bucket, Map<String, Object?> payload) async {
    values[bucket] = Map<String, Object?>.from(payload);
  }

  @override
  Future<Map<String, Object?>?> load(StorageBucket bucket) async {
    final value = values[bucket];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete(StorageBucket bucket) async {
    values.remove(bucket);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test('persists and restores bookmarks with custom collections', () async {
    final storage = _MemoryStorage();
    final repository = LocalBookmarkRepository(storage);
    final bookmark = UserBookmark(
      wordId: 'brot',
      addedAt: DateTime.utc(2026, 10, 3, 18),
      collections: const <String>['أساسيات', 'طعام', 'طعام'],
    );

    await repository.saveBookmark(bookmark);
    final restored = await repository.loadBookmarks();

    expect(storage.values, contains(StorageBucket.lexiconUserData));
    expect(restored, hasLength(1));
    expect(restored.single.wordId, 'brot');
    expect(restored.single.collections.toSet(), <String>{'أساسيات', 'طعام'});
  });

  test('persists personal note and private examples locally', () async {
    final storage = _MemoryStorage();
    final repository = LocalBookmarkRepository(storage);
    await repository.saveNote(
      WordPersonalNote(
        wordId: 'brot',
        note: '  كلمة يومية  ',
        examples: const <String>['Ich kaufe Brot.', 'Ich kaufe Brot.', ''],
        updatedAt: DateTime.utc(2026, 10, 3),
      ),
    );

    final notes = await repository.loadNotes();

    expect(notes['brot']?.note, 'كلمة يومية');
    expect(notes['brot']?.examples, <String>['Ich kaufe Brot.']);
  });

  test('bookmark removal keeps notes and note removal keeps bookmarks', () async {
    final storage = _MemoryStorage();
    final repository = LocalBookmarkRepository(storage);
    await repository.saveBookmark(
      UserBookmark(wordId: 'brot', addedAt: DateTime.utc(2026, 10, 3)),
    );
    await repository.saveNote(
      WordPersonalNote(
        wordId: 'brot',
        note: 'ملاحظة',
        updatedAt: DateTime.utc(2026, 10, 3),
      ),
    );

    await repository.removeBookmark('brot');
    expect(await repository.loadBookmarks(), isEmpty);
    expect((await repository.loadNotes())['brot'], isNotNull);

    await repository.saveBookmark(
      UserBookmark(wordId: 'brot', addedAt: DateTime.utc(2026, 10, 3)),
    );
    await repository.removeNote('brot');
    expect(await repository.loadBookmarks(), hasLength(1));
    expect(await repository.loadNotes(), isEmpty);
  });
}
