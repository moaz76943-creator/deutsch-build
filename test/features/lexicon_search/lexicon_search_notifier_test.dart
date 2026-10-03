import 'package:deutsch_bilarabi/features/lexicon_search/application/lexicon_search_notifier.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/domain/lexicon_models.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/domain/lexicon_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

final class _SearchRepository implements LexiconSearchRepository {
  final List<String> queries = <String>[];
  final Map<String, SearchResultItem> items = <String, SearchResultItem>{};

  @override
  Future<SearchResultItem?> byId(String wordId) async => items[wordId];

  @override
  Future<List<SearchResultItem>> search(LexiconSearchQuery query) async {
    queries.add(query.text);
    final item = SearchResultItem(
      wordId: query.text,
      germanWord: query.text,
      arabicMeaning: 'نتيجة',
      cefrLevel: 'A1',
    );
    items[item.wordId] = item;
    return <SearchResultItem>[item];
  }
}

final class _BookmarkRepository implements BookmarkRepository {
  final Map<String, UserBookmark> bookmarks = <String, UserBookmark>{};
  final Map<String, WordPersonalNote> notes = <String, WordPersonalNote>{};

  @override
  Future<List<UserBookmark>> loadBookmarks() async => bookmarks.values.toList();

  @override
  Future<Map<String, WordPersonalNote>> loadNotes() async => Map.of(notes);

  @override
  Future<void> removeBookmark(String wordId) async => bookmarks.remove(wordId);

  @override
  Future<void> removeNote(String wordId) async => notes.remove(wordId);

  @override
  Future<void> saveBookmark(UserBookmark bookmark) async {
    bookmarks[bookmark.wordId] = bookmark;
  }

  @override
  Future<void> saveNote(WordPersonalNote note) async {
    notes[note.wordId] = note;
  }
}

void main() {
  test('debounced typing runs only the latest lexicon query', () async {
    final search = _SearchRepository();
    final notifier = LexiconSearchNotifier(
      searchRepository: search,
      bookmarkRepository: _BookmarkRepository(),
      debounceDuration: const Duration(milliseconds: 20),
    );

    notifier.updateText('b');
    notifier.updateText('bu');
    notifier.updateText('buch');
    await Future<void>.delayed(const Duration(milliseconds: 45));

    expect(search.queries, <String>['buch']);
    expect(notifier.state.results.single.germanWord, 'buch');
    notifier.dispose();
  });

  test('bookmark collections and personal note are persisted through notifier',
      () async {
    final search = _SearchRepository();
    final bookmarks = _BookmarkRepository();
    final notifier = LexiconSearchNotifier(
      searchRepository: search,
      bookmarkRepository: bookmarks,
      debounceDuration: Duration.zero,
    );
    const item = SearchResultItem(
      wordId: 'brot',
      germanWord: 'Brot',
      arabicMeaning: 'خبز',
      cefrLevel: 'A1',
      article: LexiconArticle.das,
    );

    await notifier.toggleBookmark(item, collections: const <String>['طعام']);
    await notifier.saveNote(
      item.wordId,
      'مهم',
      examples: const <String>['Ich esse Brot.'],
    );

    expect(notifier.isBookmarked('brot'), isTrue);
    expect(bookmarks.bookmarks['brot']?.collections, <String>['طعام']);
    expect(notifier.noteFor('brot')?.examples, <String>['Ich esse Brot.']);
    notifier.dispose();
  });
}
