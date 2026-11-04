/// Task 1432: Calibrates syllable-per-minute articulation against CEFR thresholds
class SyllableTempoCalibrator {
  String classifyPace(double syllablesPerSec) => syllablesPerSec < 2.0 ? 'A1' : (syllablesPerSec < 3.5 ? 'B1' : 'C1');
}
