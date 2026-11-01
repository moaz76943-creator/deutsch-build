class BimodalInputSynchronizer {
  final List<String> words;
  final List<int> timestampsMs;
  const BimodalInputSynchronizer({required this.words, required this.timestampsMs});
  int? getActiveIndex(int currentMs) {
    for (int i = 0; i < timestampsMs.length; i++) {
      if (currentMs <= timestampsMs[i]) return i;
    }
    return words.isEmpty ? null : words.length - 1;
  }
}
