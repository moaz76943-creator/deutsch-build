/// Task 1314: Relative clause pronoun concord matcher
class RelativePronounMatcher {
  String matchPronoun(String gender, String grammaticalCase) => (gender == 'Masc' && grammaticalCase == 'Akk') ? 'den' : 'der';
}
