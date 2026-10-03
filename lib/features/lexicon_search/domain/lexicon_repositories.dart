import 'lexicon_models.dart';

abstract interface class LexiconSearchRepository {
  Future<List<SearchResultItem>> search(LexiconSearchQuery query);

  Future<SearchResultItem?> byId(String wordId);
}

abstract interface class BookmarkRepository {
  Future<List<UserBookmark>> loadBookmarks();

  Future<void> saveBookmark(UserBookmark bookmark);

  Future<void> removeBookmark(String wordId);

  Future<Map<String, WordPersonalNote>> loadNotes();

  Future<void> saveNote(WordPersonalNote note);

  Future<void> removeNote(String wordId);
}
