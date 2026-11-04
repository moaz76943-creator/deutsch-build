/// Task 1393: Transforms partitive constructions (ein Glas Wasser vs un verre d'eau)
class PartitiveTransformer {
  String formatPartitive(String container, String content, String lang) => lang == 'de' ? '$container $content' : '$container de $content';
}
