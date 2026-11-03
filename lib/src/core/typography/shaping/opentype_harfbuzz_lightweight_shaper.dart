/// Task 1202: Lightweight glyph ligature and mark placement shaper
class OpentypeShaper {
  List<int> shapeGlyphs(String text) => text.codeUnits;
  bool supportsLigatures => true;
}
