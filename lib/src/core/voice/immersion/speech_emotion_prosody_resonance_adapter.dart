/// Task 1194: Adapts voice synthesis warmth, urgency, or curiosity
enum ImmersionMood { neutral, encouraging, urgent, curious }
class EmotionProsodyAdapter {
  double getPitchShift(ImmersionMood mood) => mood == ImmersionMood.encouraging ? 1.05 : 1.0;
}
