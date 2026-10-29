import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary_item.dart';
import '../repositories/vocabulary_repository.dart';

final vocabularyRepositoryProvider = Provider((ref) => VocabularyRepository());

final vocabularyListProvider = StateNotifierProvider<VocabularyNotifier, List<VocabularyItem>>((ref) {
  final repo = ref.watch(vocabularyRepositoryProvider);
  return VocabularyNotifier(repo);
});

class VocabularyNotifier extends StateNotifier<List<VocabularyItem>> {
  final VocabularyRepository _repository;

  VocabularyNotifier(this._repository) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    final rawList = await _repository.getVocabularyList();
    state = rawList.map((e) => VocabularyItem.fromJson(e)).toList();
  }

  Future<void> addItem(VocabularyItem item) async {
    state = [item, ...state];
    await _save();
  }

  Future<void> removeItem(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
    await _save();
  }

  Future<void> updateItem(int index, VocabularyItem updated) async {
    state = [
      for (int i = 0; i < state.length; i++)
        i == index ? updated : state[i]
    ];
    await _save();
  }

  Future<void> _save() async {
    final rawList = state.map((e) => e.toJson()).toList();
    await _repository.saveVocabularyList(rawList);
  }
}
