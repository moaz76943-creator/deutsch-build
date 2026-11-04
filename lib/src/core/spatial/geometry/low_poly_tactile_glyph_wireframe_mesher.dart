/// Task 1628: Generates low-poly 3D wireframe meshes of complex glyphs
class LowPolyGlyphMesher {
  int getPolygonCount(String script) => script == 'Arabic' ? 128 : 64;
}
