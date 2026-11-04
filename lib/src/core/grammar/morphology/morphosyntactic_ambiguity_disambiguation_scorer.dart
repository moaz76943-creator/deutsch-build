/// Task 1338: Disambiguation scorer resolving homographs ('sie' = she/they/you)
class MorphosyntacticDisambiguator {
  String disambiguateSie(bool isCapitalized, String verbEnding) => isCapitalized ? 'YOU_FORMAL' : (verbEnding == 't' ? 'SHE' : 'THEY');
}
