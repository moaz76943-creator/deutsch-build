import 'search_models.dart';

abstract interface class SearchRepository {
  Future<List<SearchResultItem>> search(SearchQuery query);

  Future<SearchResultItem?> byId(String id);
}

abstract interface class BookmarksRepository {
  Future<List<UserBookmark>> loadBookmarks();

  Future<void> saveBookmark(UserBookmark bookmark);

  Future<void> removeBookmark(String wordId);

  Future<Map<String, CustomWordNote>> loadNotes();

  Future<void> saveNote(CustomWordNote note);

  Future<void> removeNote(String wordId);
}
