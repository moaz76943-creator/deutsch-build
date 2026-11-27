import '../entities/vocabulary_item.dart';

/// Abstract repository — domain knows nothing about how data is stored.
/// Enables easy mocking for unit tests and swapping implementations (secure, encrypted, etc.).
abstract class VocabularyRepository {
  Future<List<VocabularyItem>> getItems({String? packId, int? limit});
  Future<void> markKnown(String id);
  Future<void> addCustom(VocabularyItem item);
}
