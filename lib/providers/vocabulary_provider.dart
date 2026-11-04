import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deutsch_bilarabi/models/vocabulary_item.dart';
import 'package:deutsch_bilarabi/repositories/vocabulary_repository.dart';

/// Repository provider — injectable for tests via overrideWith.
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) => VocabularyRepository());

/// Optimized AsyncNotifier for vocabulary list.
/// - Provides loading/error/data states out of the box (AsyncValue).
/// - Lazy loads on first watch.
/// - Better error propagation without blocking UI.
/// - Easier testing with overrides.
final vocabularyListProvider =
    AsyncNotifierProvider<VocabularyNotifier, List<VocabularyItem>>(
  VocabularyNotifier.new,
);

class VocabularyNotifier extends AsyncNotifier<List<VocabularyItem>> {
  VocabularyRepository get _repository => ref.read(vocabularyRepositoryProvider);

  @override
  Future<List<VocabularyItem>> build() async {
    final rawList = await _repository.getVocabularyList();
    return rawList.map((e) => VocabularyItem.fromJson(e)).toList();
  }

  Future<void> addItem(VocabularyItem item) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([item, ...current]);
    await _save([item, ...current]);
  }

  Future<void> removeItem(int index) async {
    final current = state.valueOrNull ?? [];
    if (index < 0 || index >= current.length) return;
    final updated = [
      for (int i = 0; i < current.length; i++)
        if (i != index) current[i]
    ];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> updateItem(int index, VocabularyItem updatedItem) async {
    final current = state.valueOrNull ?? [];
    if (index < 0 || index >= current.length) return;
    final updated = [
      for (int i = 0; i < current.length; i++) i == index ? updatedItem : current[i]
    ];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> _save(List<VocabularyItem> items) async {
    final rawList = items.map((e) => e.toJson()).toList();
    await _repository.saveVocabularyList(rawList);
  }
}
