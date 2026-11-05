/// Round-based Feature: Live Fluency & Pace Coach
class VoiceFluencyCoach {
  final int round = 689;
  double evaluatePace(int wpm) => wpm >= 110 && wpm <= 150 ? 1.0 : 0.8;
  String getAdvice(int wpm) => wpm < 110 ? 'حاول التحدث بسرعة أكبر قليلاً.' : 'سرعة نطقك ممتازة وطبيعية.';
}
