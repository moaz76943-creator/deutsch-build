/// Task 1244: Sonority Sequencing Principle (SSP) syllable division ranker
class SyllableSonorityRanker {
  int getSonority(String char) => 'aeiouäöü'.contains(char.toLowerCase()) ? 5 : 1;
}
