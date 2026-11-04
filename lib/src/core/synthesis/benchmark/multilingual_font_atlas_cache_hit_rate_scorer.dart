/// Task 1873: Glyph cache hit-rate scorer for complex scripts (Arabic, CJK)
class GlyphAtlasHitRateScorer {
  double computeHitRate(int hits, int misses) => (hits + misses) > 0 ? hits / (hits + misses) : 1.0;
}
