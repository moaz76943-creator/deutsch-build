/// Task 1637: Haptic tactile metronome pulsing rhythmic feet
class TactileRhythmMetronome {
  int getIntervalMs(double bpm) => bpm > 0 ? (60000 / bpm).round() : 500;
}
