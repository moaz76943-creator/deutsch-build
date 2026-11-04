/// Task 1752: KWIC (Keyword-in-Context) bilingual concordancer
class BilingualConcordancerKwic {
  List> searchKwic(String query, List> corpus) {
    return corpus.where((e) => (e['src'] ?? '').contains(query)).toList();
  }
}
