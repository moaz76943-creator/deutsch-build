/// Task 2045: Generates dynamic contextual cloze challenges exchanged over mesh Bluetooth
class CrossPeerClozeChallengeGenerator {
  Map<String, String> generateCloze(String sentence, String targetWord) => {
    'masked': sentence.replaceAll(targetWord, '______'),
    'solution': targetWord
  };
}
