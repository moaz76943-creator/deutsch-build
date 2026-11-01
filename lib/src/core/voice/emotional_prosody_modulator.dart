enum EmotionalState { neutral, encouraging, calm, focused }
class EmotionalProsodyModulator {
  final EmotionalState state;
  const EmotionalProsodyModulator({this.state = EmotionalState.neutral});
}
