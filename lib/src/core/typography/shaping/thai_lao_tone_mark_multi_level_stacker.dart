/// Task 1215: Four-level vertical glyph stacking for Thai/Lao
class ThaiToneMarkStacker {
  int getVerticalLevel(int charCode) => (charCode >= 0x0E48 && charCode <= 0x0E4B) ? 2 : 1;
}
