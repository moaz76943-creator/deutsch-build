/// Task 1672: Anchors polysemous words across multiple rooms with links
class PolysemyBranchingAnchor {
  final Map<String, List<String>> _meanings = {};
  void addLocusMeaning(String lemma, String locusId) => _meanings.putIfAbsent(lemma, () => []).add(locusId);
  List<String> getLociForLemma(String lemma) => _meanings[lemma] ?? [];
}
