/// Task 2065: Reflexive verb case governor discriminating dative vs accusative reflexives
class ReflexiveCaseGovernor {
  String getReflexivePronoun(String person, String verb) => verb == 'vorstellen_dative' ? 'mir' : 'mich';
}
