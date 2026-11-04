/// Task 1222: Dynamic LRU texture atlas allocator for rendered font glyphs
class GlyphTextureAtlasAllocator {
  final Map<int, List<int>> _atlas = {};
  void insertGlyph(int glyphId, List<int> bitmap) => _atlas[glyphId] = bitmap;
  bool isCached(int glyphId) => _atlas.containsKey(glyphId);
}
