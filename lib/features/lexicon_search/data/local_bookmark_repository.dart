import '../../../core/infrastructure/storage/local_storage_repository.dart';
import '../domain/lexicon_models.dart';
import '../domain/lexicon_repositories.dart';

final class LocalBookmarkRepository implements BookmarkRepository {
  LocalBookmarkRepository(this._storage);

  final LocalStorageRepository _storage;

  @override
  Future<List<UserBookmark>> loadBookmarks() async {
    final payload = await _loadPayload();
    final raw = payload['bookmarks'];
    if (raw is! List) return const <UserBookmark>[];

    final bookmarks = raw
        .whereType<Map>()
        .map((entry) => _bookmarkFromJson(Map<String, Object?>.from(entry)))
        .whereType<UserBookmark>()
        .toList(growable: false)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return List<UserBookmark>.unmodifiable(bookmarks);
  }

  @override
  Future<Map<String, WordPersonalNote>> loadNotes() async {
    final payload = await _loadPayload();
    final raw = payload['notes'];
    if (raw is! List) return const <String, WordPersonalNote>{};

    final notes = <String, WordPersonalNote>{};
    for (final entry in raw.whereType<Map>()) {
      final note = _noteFromJson(Map<String, Object?>.from(entry));
      if (note != null) notes[note.wordId] = note;
    }
    return Map<String, WordPersonalNote>.unmodifiable(notes);
  }

  @override
  Future<void> saveBookmark(UserBookmark bookmark) async {
    final bookmarks = <String, UserBookmark>{
      for (final item in await loadBookmarks()) item.wordId: item,
      bookmark.wordId: _normalizedBookmark(bookmark),
    };
    await _write(bookmarks: bookmarks.values);
  }

  @override
  Future<void> removeBookmark(String wordId) async {
    final bookmarks = <String, UserBookmark>{
      for (final item in await loadBookmarks()) item.wordId: item,
    }..remove(wordId.trim());
    await _write(bookmarks: bookmarks.values);
  }

  @override
  Future<void> saveNote(WordPersonalNote note) async {
    final notes = <String, WordPersonalNote>{
      ...await loadNotes(),
      note.wordId: _normalizedNote(note),
    };
    await _write(notes: notes.values);
  }

  @override
  Future<void> removeNote(String wordId) async {
    final notes = <String, WordPersonalNote>{...await loadNotes()}
      ..remove(wordId.trim());
    await _write(notes: notes.values);
  }

  Future<Map<String, Object?>> _loadPayload() async {
    return await _storage.load(StorageBucket.lexiconUserData) ??
        const <String, Object?>{};
  }

  Future<void> _write({
    Iterable<UserBookmark>? bookmarks,
    Iterable<WordPersonalNote>? notes,
  }) async {
    final currentBookmarks = bookmarks ?? await loadBookmarks();
    final currentNotes = notes ?? (await loadNotes()).values;
    await _storage.save(
      StorageBucket.lexiconUserData,
      <String, Object?>{
        'schema_version': 1,
        'bookmarks': currentBookmarks.map(_bookmarkToJson).toList(),
        'notes': currentNotes.map(_noteToJson).toList(),
      },
    );
  }

  UserBookmark _normalizedBookmark(UserBookmark bookmark) {
    final collections = bookmark.collections
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();
    return bookmark.copyWith(
      collections: List<String>.unmodifiable(collections),
    );
  }

  WordPersonalNote _normalizedNote(WordPersonalNote note) {
    final examples = note.examples
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    return WordPersonalNote(
      wordId: note.wordId.trim(),
      note: note.note.trim(),
      examples: List<String>.unmodifiable(examples),
      updatedAt: note.updatedAt.toUtc(),
    );
  }

  Map<String, Object?> _bookmarkToJson(UserBookmark bookmark) =>
      <String, Object?>{
        'word_id': bookmark.wordId,
        'added_at': bookmark.addedAt.toUtc().toIso8601String(),
        'collections': bookmark.collections,
      };

  Map<String, Object?> _noteToJson(WordPersonalNote note) => <String, Object?>{
        'word_id': note.wordId,
        'note': note.note,
        'examples': note.examples,
        'updated_at': note.updatedAt.toUtc().toIso8601String(),
      };

  UserBookmark? _bookmarkFromJson(Map<String, Object?> json) {
    final wordId = json['word_id'];
    final addedAt = DateTime.tryParse(json['added_at']?.toString() ?? '');
    if (wordId is! String || wordId.trim().isEmpty || addedAt == null) {
      return null;
    }
    final rawCollections = json['collections'];
    final collections = rawCollections is List
        ? rawCollections
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList(growable: false)
        : const <String>[];
    return UserBookmark(
      wordId: wordId.trim(),
      addedAt: addedAt.toUtc(),
      collections: List<String>.unmodifiable(collections),
    );
  }

  WordPersonalNote? _noteFromJson(Map<String, Object?> json) {
    final wordId = json['word_id'];
    final note = json['note'];
    final updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? '');
    if (wordId is! String || note is! String || updatedAt == null) return null;
    final rawExamples = json['examples'];
    final examples = rawExamples is List
        ? rawExamples.whereType<String>().toList(growable: false)
        : const <String>[];
    return WordPersonalNote(
      wordId: wordId.trim(),
      note: note.trim(),
      examples: List<String>.unmodifiable(examples),
      updatedAt: updatedAt.toUtc(),
    );
  }
}
