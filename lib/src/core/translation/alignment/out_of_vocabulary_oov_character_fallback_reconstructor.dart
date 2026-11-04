/// Task 1707: Character-level backoff reconstructor preventing <unk> tokens
class OovCharacterReconstructor {
  List<String> splitOov(String unknownWord) => unknownWord.split('');
}
