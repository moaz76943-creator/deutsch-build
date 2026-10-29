import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deutsch_bilarabi/models/vocabulary_item.dart';
import 'package:deutsch_bilarabi/repositories/vocabulary_repository.dart';

/// Repository provider — injectable for tests via overrideWith.
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) => VocabularyRepository());

/// AsyncNotifier for vocabulary list. Exposes AsyncValue for proper loading / data / error handling.
/// Better separation of concerns, easier testing, and prevents silent failures.
final vocabularyListProvider = AsyncNotifierProvider<VocabularyNotifier, List<VocabularyItem>>(
  VocabularyNotifier.new,
);

class VocabularyNotifier extends AsyncNotifier<List<VocabularyItem>> {
  late final VocabularyRepository _repository;

  @override
  Future<List<VocabularyItem>> build() async {
    _repository = ref.watch(vocabularyRepositoryProvider);
    return _load();
  }

  Future<List<VocabularyItem>> _load() async {
    final rawList = await _repository.getVocabularyList();
    return rawList.map((e) => VocabularyItem.fromJson(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> addItem(VocabularyItem item) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([item, ...current]);
    await _save();
  }

  Future<void> removeItem(int index) async {
    final current = state.valueOrNull ?? [];
    if (index < 0 || index >= current.length) return;
    state = AsyncData([
      for (int i = 0; i < current.length; i++)
        if (i != index) current[i]
    ]);
    await _save();
  }

  Future<void> updateItem(int index, VocabularyItem updated) async {
    final current = state.valueOrNull ?? [];
    if (index < 0 || index >= current.length) return;
    state = AsyncData([
      for (int i = 0; i < current.length; i++) i == index ? updated : current[i]
    ]);
    await _save();
  }

  Future<void> _save() async {
    final current = state.valueOrNull ?? [];
    final rawList = current.map((e) => e.toJson()).toList();
    await _repository.saveVocabularyList(rawList);
  }
}
