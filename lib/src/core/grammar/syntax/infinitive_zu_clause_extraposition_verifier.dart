/// Task 1315: Infinitiv mit 'zu' extraposition verifier
class InfinitiveZuVerifier {
  bool hasZuInfinitive(List<String> tokens) => tokens.contains('zu') || tokens.any((t) => t.contains('zu'));
}
