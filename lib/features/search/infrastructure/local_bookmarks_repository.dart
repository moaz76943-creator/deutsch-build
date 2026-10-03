import 'dart:convert';

import '../../../services/preferences_service.dart';
import '../../../services/user_vocabulary_service.dart';
import '../domain/search_models.dart';
import '../domain/search_repositories.dart';

final class LocalBookmarksRepository implements BookmarksRepository {
  LocalBookmarksRepository({
    required FavoritesRepository favorites,
    required PreferencesService preferences,
    required SearchRepository searchRepository,
  })  : _favorites = favorites,
        _preferences = preferences,
        _searchRepository = searchRepository;

  static const String notesKey = 'search_custom_word_notes_v1';

  final FavoritesRepository _favorites;
  final PreferencesService _preferences;
  final SearchRepository _searchRepository;

  @override
  Future<List<UserBookmark>> loadBookmarks() async {
    final ids = (await _favorites.getFavorites()).toList(growable: false)
      ..sort();
    final bookmarks = <UserBookmark>[];
    for (final id in ids) {
      final item = await _searchRepository.byId(id);
      if (item != null) bookmarks.add(UserBookmark(item: item));
    }
    return List<UserBookmark>.unmodifiable(bookmarks);
  }

  @override
  Future<void> saveBookmark(UserBookmark bookmark) async {
    if (!await _favorites.isFavorite(bookmark.item.id)) {
      await _favorites.toggleFavorite(bookmark.item.id);
    }
  }

  @override
  Future<void> removeBookmark(String wordId) async {
    if (await _favorites.isFavorite(wordId)) {
      await _favorites.toggleFavorite(wordId);
    }
  }

  @override
  Future<Map<String, CustomWordNote>> loadNotes() async {
    final raw = _preferences.readText(notesKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <String, CustomWordNote>{};
    }

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const <String, CustomWordNote>{};
    }
    if (decoded is! List) return const <String, CustomWordNote>{};

    final notes = <String, CustomWordNote>{};
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final note = _noteFromJson(Map<String, Object?>.from(entry));
      if (note != null) notes[note.wordId] = note;
    }
    return Map<String, CustomWordNote>.unmodifiable(notes);
  }

  @override
  Future<void> saveNote(CustomWordNote note) async {
    final notes = <String, CustomWordNote>{
      ...await loadNotes(),
      note.wordId: note,
    };
    await _persistNotes(notes);
  }

  @override
  Future<void> removeNote(String wordId) async {
    final notes = <String, CustomWordNote>{...await loadNotes()}
      ..remove(wordId);
    await _persistNotes(notes);
  }

  Future<void> _persistNotes(Map<String, CustomWordNote> notes) async {
    final value = jsonEncode(
      notes.values.map(_noteToJson).toList(growable: false),
    );
    await _preferences.writeText(notesKey, value);
  }

  Map<String, Object?> _noteToJson(CustomWordNote note) => <String, Object?>{
        'wordId': note.wordId,
        'text': note.text,
        'updatedAt': note.updatedAt.toIso8601String(),
      };

  CustomWordNote? _noteFromJson(Map<String, Object?> json) {
    final wordId = json['wordId'];
    final text = json['text'];
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    if (wordId is! String || text is! String || updatedAt == null) return null;
    return CustomWordNote(wordId: wordId, text: text, updatedAt: updatedAt);
  }
}
