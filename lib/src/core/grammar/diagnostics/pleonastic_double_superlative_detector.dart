/// Task 1354: Flags pleonastic superlatives (am optimalsten, am einzigsten)
class PleonasticSuperlativeDetector {
  bool isAbsoluteAdjectiveExaggerated(String adj) => adj.contains('optimalst') || adj.contains('einzigst');
}
