/// Task 1217: Algorithmic composition of Jamo into Korean Hangul syllables
class HangulJamoComposer {
  int composeSyllable(int initial, int peak, int finalJamo) => 0xAC00 + (initial * 21 + peak) * 28 + finalJamo;
}
