/// Task 1157: Isochrony rhythm analyzer (stress-timed vs syllable-timed)
class IsochronyRhythmGrader {
  double gradeRhythm(bool isStressTimed, double variance) => isStressTimed ? (variance > 0.3 ? 95.0 : 70.0) : (variance < 0.2 ? 95.0 : 70.0);
}
