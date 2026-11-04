/// Task 1216: German orthographic rules (ß -> SS / ẞ, umlauts)
class GermanOrthographyGuard {
  String capitalizeEszett(String text, bool useCapitalSharpS) => useCapitalSharpS ? text.replaceAll('ß', 'ẞ') : text.replaceAll('ß', 'SS');
}
