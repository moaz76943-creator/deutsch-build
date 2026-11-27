import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vocabulary_item.dart';
import '../../domain/repositories/vocabulary_repository.dart';

// Placeholder — wire to real data source in next iteration.
// This demonstrates the DI pattern that makes development fast and testable.
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  // TODO: return VocabularyRepositoryImpl(ref.watch(localDataSourceProvider));
  throw UnimplementedError('Wire data layer next');
});

final vocabularyItemsProvider =
    FutureProvider.family<List<VocabularyItem>, String?>((ref, packId) {
  final repo = ref.watch(vocabularyRepositoryProvider);
  return repo.getItems(packId: packId);
});
