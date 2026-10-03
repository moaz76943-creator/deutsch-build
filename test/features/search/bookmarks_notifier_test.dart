import 'package:deutsch_bilarabi/features/search/application/bookmarks_notifier.dart';
import 'package:deutsch_bilarabi/features/search/domain/search_models.dart';
import 'package:deutsch_bilarabi/features/search/domain/search_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

final class _MemoryBookmarksRepository implements BookmarksRepository {
  final Map<String, UserBookmark> bookmarks = <String, UserBookmark>{};
  final Map<String, CustomWordNote> notes = <String, CustomWordNote>{};

  @override
  Future<List<UserBookmark>> loadBookmarks() async => bookmarks.values.toList();

  @override
  Future<Map<String, CustomWordNote>> loadNotes() async => Map.of(notes);

  @override
  Future<void> removeBookmark(String wordId) async {
    bookmarks.remove(wordId);
  }

  @override
  Future<void> removeNote(String wordId) async {
    notes.remove(wordId);
  }

  @override
  Future<void> saveBookmark(UserBookmark bookmark) async {
    bookmarks[bookmark.item.id] = bookmark;
  }

  @override
  Future<void> saveNote(CustomWordNote note) async {
    notes[note.wordId] = note;
  }
}

void main() {
  const item = SearchResultItem(
    id: 'brot',
    term: 'Brot',
    translationArabic: 'خبز',
    type: SearchItemType.noun,
    article: GermanArticle.das,
  );

  test('toggle adds and removes a favorite through the domain repository', () async {
    final repository = _MemoryBookmarksRepository();
    final notifier = BookmarksNotifier(repository: repository);

    await notifier.toggle(item);
    expect(notifier.isFavorite('brot'), isTrue);
    expect(repository.bookmarks, contains('brot'));

    await notifier.toggle(item);
    expect(notifier.isFavorite('brot'), isFalse);
    expect(repository.bookmarks, isNot(contains('brot')));
    notifier.dispose();
  });

  test('custom notes are trimmed persisted updated and removable', () async {
    final repository = _MemoryBookmarksRepository();
    final notifier = BookmarksNotifier(repository: repository);

    await notifier.saveNote('brot', '  تذكّر النطق الطويل  ');
    expect(notifier.noteFor('brot')?.text, 'تذكّر النطق الطويل');
    expect(repository.notes['brot']?.text, 'تذكّر النطق الطويل');

    await notifier.saveNote('brot', '');
    expect(notifier.noteFor('brot'), isNull);
    expect(repository.notes, isNot(contains('brot')));
    notifier.dispose();
  });

  test('load restores persisted bookmarks and notes', () async {
    final repository = _MemoryBookmarksRepository();
    repository.bookmarks['brot'] = UserBookmark(
      item: item,
      createdAt: DateTime.utc(2026, 10, 3),
    );
    repository.notes['brot'] = CustomWordNote(
      wordId: 'brot',
      text: 'ملاحظة',
      updatedAt: DateTime.utc(2026, 10, 3),
    );
    final notifier = BookmarksNotifier(repository: repository);

    await notifier.load();

    expect(notifier.isFavorite('brot'), isTrue);
    expect(notifier.noteFor('brot')?.text, 'ملاحظة');
    notifier.dispose();
  });
}
