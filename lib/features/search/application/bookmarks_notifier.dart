import 'package:flutter/foundation.dart';

import '../domain/search_models.dart';
import '../domain/search_repositories.dart';

final class BookmarksState {
  const BookmarksState({
    this.bookmarks = const <UserBookmark>[],
    this.notes = const <String, CustomWordNote>{},
    this.isLoading = false,
    this.errorMessage,
  });

  final List<UserBookmark> bookmarks;
  final Map<String, CustomWordNote> notes;
  final bool isLoading;
  final String? errorMessage;
}

class BookmarksNotifier extends ChangeNotifier {
  BookmarksNotifier({required BookmarksRepository repository})
      : _repository = repository;

  final BookmarksRepository _repository;
  BookmarksState _state = const BookmarksState();

  BookmarksState get state => _state;

  bool isFavorite(String wordId) =>
      _state.bookmarks.any((bookmark) => bookmark.item.id == wordId);

  CustomWordNote? noteFor(String wordId) => _state.notes[wordId];

  Future<void> load() async {
    _setState(
      BookmarksState(
        bookmarks: _state.bookmarks,
        notes: _state.notes,
        isLoading: true,
      ),
    );
    try {
      final bookmarks = await _repository.loadBookmarks();
      final notes = await _repository.loadNotes();
      _setState(
        BookmarksState(
          bookmarks: List<UserBookmark>.unmodifiable(bookmarks),
          notes: Map<String, CustomWordNote>.unmodifiable(notes),
        ),
      );
    } catch (error) {
      _setState(
        BookmarksState(
          bookmarks: _state.bookmarks,
          notes: _state.notes,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> toggle(SearchResultItem item) async {
    final existing = _state.bookmarks.where(
      (bookmark) => bookmark.item.id == item.id,
    );
    if (existing.isNotEmpty) {
      await _repository.removeBookmark(item.id);
      final remaining = _state.bookmarks
          .where((bookmark) => bookmark.item.id != item.id)
          .toList(growable: false);
      _setState(
        BookmarksState(
          bookmarks: List<UserBookmark>.unmodifiable(remaining),
          notes: _state.notes,
        ),
      );
      return;
    }

    final bookmark = UserBookmark(item: item, createdAt: DateTime.now().toUtc());
    await _repository.saveBookmark(bookmark);
    _setState(
      BookmarksState(
        bookmarks: List<UserBookmark>.unmodifiable(
          <UserBookmark>[bookmark, ..._state.bookmarks],
        ),
        notes: _state.notes,
      ),
    );
  }

  Future<void> saveNote(String wordId, String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      await removeNote(wordId);
      return;
    }
    final note = CustomWordNote(
      wordId: wordId,
      text: normalized,
      updatedAt: DateTime.now().toUtc(),
    );
    await _repository.saveNote(note);
    _setState(
      BookmarksState(
        bookmarks: _state.bookmarks,
        notes: Map<String, CustomWordNote>.unmodifiable(
          <String, CustomWordNote>{..._state.notes, wordId: note},
        ),
      ),
    );
  }

  Future<void> removeNote(String wordId) async {
    await _repository.removeNote(wordId);
    final notes = <String, CustomWordNote>{..._state.notes}..remove(wordId);
    _setState(
      BookmarksState(
        bookmarks: _state.bookmarks,
        notes: Map<String, CustomWordNote>.unmodifiable(notes),
      ),
    );
  }

  void _setState(BookmarksState value) {
    _state = value;
    notifyListeners();
  }
}
