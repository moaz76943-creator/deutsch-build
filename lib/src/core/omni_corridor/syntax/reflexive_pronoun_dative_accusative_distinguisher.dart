/// Task 1955: Distinguishes reflexive pronouns between dative and accusative (mir vs mich)
class ReflexivePronounDistinguisher {
  String getReflexive(String person, String requiredCase, String lang) => requiredCase == 'dative' ? 'mir' : 'mich';
}
