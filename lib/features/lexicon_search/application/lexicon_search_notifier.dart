import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/lexicon_models.dart';
import '../domain/lexicon_repositories.dart';

final class LexiconSearchState {
  const LexiconSearchState({
    this.query = const LexiconSearchQuery(),
    this.results = const <SearchResultItem>[],
    this.bookmarks = const <UserBookmark>[],
    this.bookmarkItems = const <String, SearchResultItem>{},
    this.notes = const <String, WordPersonalNote>{},
    this.isSearching = false,
    this.isLoadingUserData = false,
    this.errorMessage,
  });

  final LexiconSearchQuery query;
  final List<SearchResultItem> results;
  final List<UserBookmark> bookmarks;
  final Map<String, SearchResultItem> bookmarkItems;
  final Map<String, WordPersonalNote> notes;
  final bool isSearching;
  final bool isLoadingUserData;
  final String? errorMessage;

  LexiconSearchState copyWith({
    LexiconSearchQuery? query,
    List<SearchResultItem>? results,
    List<UserBookmark>? bookmarks,
    Map<String, SearchResultItem>? bookmarkItems,
    Map<String, WordPersonalNote>? notes,
    bool? isSearching,
    bool? isLoadingUserData,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LexiconSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      bookmarks: bookmarks ?? this.bookmarks,
      bookmarkItems: bookmarkItems ?? this.bookmarkItems,
      notes: notes ?? this.notes,
      isSearching: isSearching ?? this.isSearching,
      isLoadingUserData: isLoadingUserData ?? this.isLoadingUserData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final class LexiconSearchNotifier extends ChangeNotifier {
  LexiconSearchNotifier({
    required LexiconSearchRepository searchRepository,
    required BookmarkRepository bookmarkRepository,
    this.debounceDuration = const Duration(milliseconds: 220),
  })  : _searchRepository = searchRepository,
        _bookmarkRepository = bookmarkRepository;

  final LexiconSearchRepository _searchRepository;
  final BookmarkRepository _bookmarkRepository;
  final Duration debounceDuration;

  Timer? _debounce;
  int _searchEpoch = 0;
  bool _disposed = false;
  LexiconSearchState _state = const LexiconSearchState();

  LexiconSearchState get state => _state;

  bool isBookmarked(String wordId) =>
      _state.bookmarks.any((bookmark) => bookmark.wordId == wordId);

  WordPersonalNote? noteFor(String wordId) => _state.notes[wordId];

  Future<void> initialize() async {
    _ensureActive();
    _setState(_state.copyWith(isLoadingUserData: true, clearError: true));
    try {
      final bookmarks = await _bookmarkRepository.loadBookmarks();
      final notes = await _bookmarkRepository.loadNotes();
      final items = <String, SearchResultItem>{};
      for (final bookmark in bookmarks) {
        final item = await _searchRepository.byId(bookmark.wordId);
        if (item != null) items[bookmark.wordId] = item;
      }
      _setState(
        _state.copyWith(
          bookmarks: List<UserBookmark>.unmodifiable(bookmarks),
          bookmarkItems: Map<String, SearchResultItem>.unmodifiable(items),
          notes: Map<String, WordPersonalNote>.unmodifiable(notes),
          isLoadingUserData: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          isLoadingUserData: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void updateText(String value) {
    _ensureActive();
    _setState(
      _state.copyWith(
        query: _state.query.copyWith(text: value),
        isSearching: true,
        clearError: true,
      ),
    );
    _scheduleSearch();
  }

  void toggleArticle(LexiconArticle article) {
    _ensureActive();
    final articles = <LexiconArticle>{..._state.query.filters.articles};
    if (!articles.add(article)) articles.remove(article);
    _setFilters(_state.query.filters.copyWith(
      articles: Set<LexiconArticle>.unmodifiable(articles),
    ));
  }

  void toggleCefrLevel(String level) {
    _ensureActive();
    final normalized = level.trim().toUpperCase();
    if (normalized.isEmpty) return;
    final levels = <String>{..._state.query.filters.cefrLevels};
    if (!levels.add(normalized)) levels.remove(normalized);
    _setFilters(_state.query.filters.copyWith(
      cefrLevels: Set<String>.unmodifiable(levels),
    ));
  }

  Future<void> searchNow() {
    _ensureActive();
    _debounce?.cancel();
    return _executeSearch(++_searchEpoch);
  }

  Future<void> toggleBookmark(
    SearchResultItem item, {
    List<String> collections = const <String>[],
  }) async {
    _ensureActive();
    final existing = _state.bookmarks.where(
      (bookmark) => bookmark.wordId == item.wordId,
    );
    if (existing.isNotEmpty) {
      await _bookmarkRepository.removeBookmark(item.wordId);
      final bookmarks = _state.bookmarks
          .where((bookmark) => bookmark.wordId != item.wordId)
          .toList(growable: false);
      final items = <String, SearchResultItem>{..._state.bookmarkItems}
        ..remove(item.wordId);
      _setState(_state.copyWith(
        bookmarks: List<UserBookmark>.unmodifiable(bookmarks),
        bookmarkItems: Map<String, SearchResultItem>.unmodifiable(items),
      ));
      return;
    }

    final bookmark = UserBookmark(
      wordId: item.wordId,
      addedAt: DateTime.now().toUtc(),
      collections: collections,
    );
    await _bookmarkRepository.saveBookmark(bookmark);
    _setState(_state.copyWith(
      bookmarks: List<UserBookmark>.unmodifiable(
        <UserBookmark>[bookmark, ..._state.bookmarks],
      ),
      bookmarkItems: Map<String, SearchResultItem>.unmodifiable(
        <String, SearchResultItem>{..._state.bookmarkItems, item.wordId: item},
      ),
    ));
  }

  Future<void> updateCollections(
    String wordId,
    List<String> collections,
  ) async {
    _ensureActive();
    final index = _state.bookmarks.indexWhere((item) => item.wordId == wordId);
    if (index < 0) return;
    final updated = _state.bookmarks[index].copyWith(collections: collections);
    await _bookmarkRepository.saveBookmark(updated);
    final bookmarks = <UserBookmark>[..._state.bookmarks]..[index] = updated;
    _setState(_state.copyWith(
      bookmarks: List<UserBookmark>.unmodifiable(bookmarks),
    ));
  }

  Future<void> saveNote(
    String wordId,
    String note, {
    List<String> examples = const <String>[],
  }) async {
    _ensureActive();
    final normalizedNote = note.trim();
    final normalizedExamples = examples
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalizedNote.isEmpty && normalizedExamples.isEmpty) {
      await removeNote(wordId);
      return;
    }
    final value = WordPersonalNote(
      wordId: wordId,
      note: normalizedNote,
      examples: normalizedExamples,
      updatedAt: DateTime.now().toUtc(),
    );
    await _bookmarkRepository.saveNote(value);
    _setState(_state.copyWith(
      notes: Map<String, WordPersonalNote>.unmodifiable(
        <String, WordPersonalNote>{..._state.notes, wordId: value},
      ),
    ));
  }

  Future<void> removeNote(String wordId) async {
    _ensureActive();
    await _bookmarkRepository.removeNote(wordId);
    final notes = <String, WordPersonalNote>{..._state.notes}..remove(wordId);
    _setState(_state.copyWith(
      notes: Map<String, WordPersonalNote>.unmodifiable(notes),
    ));
  }

  void _setFilters(LexiconSearchFilters filters) {
    _setState(
      _state.copyWith(
        query: _state.query.copyWith(filters: filters),
        isSearching: true,
        clearError: true,
      ),
    );
    _scheduleSearch(immediate: true);
  }

  void _scheduleSearch({bool immediate = false}) {
    _debounce?.cancel();
    final epoch = ++_searchEpoch;
    if (immediate || debounceDuration == Duration.zero) {
      unawaited(_executeSearch(epoch));
      return;
    }
    _debounce = Timer(debounceDuration, () => unawaited(_executeSearch(epoch)));
  }

  Future<void> _executeSearch(int epoch) async {
    final query = _state.query;
    try {
      final results = await _searchRepository.search(query);
      if (_disposed || epoch != _searchEpoch) return;
      _setState(_state.copyWith(
        results: List<SearchResultItem>.unmodifiable(results),
        isSearching: false,
        clearError: true,
      ));
    } catch (error) {
      if (_disposed || epoch != _searchEpoch) return;
      _setState(_state.copyWith(
        isSearching: false,
        errorMessage: error.toString(),
      ));
    }
  }

  void _setState(LexiconSearchState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  void _ensureActive() {
    if (_disposed) throw StateError('LexiconSearchNotifier is disposed');
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _debounce?.cancel();
    _searchEpoch += 1;
    super.dispose();
  }
}
