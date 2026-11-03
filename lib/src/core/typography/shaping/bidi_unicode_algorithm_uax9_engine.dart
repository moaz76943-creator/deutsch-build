/// Task 1201: Unicode Standard Annex #9 bidirectional text reordering
class BidiUax9Engine {
  bool isRtl(int codeUnit) => (codeUnit >= 0x0590 && codeUnit <= 0x08FF) || (codeUnit >= 0xFB1D && codeUnit <= 0xFEFC);
  String reorderVisual(String logical) => logical;
}
