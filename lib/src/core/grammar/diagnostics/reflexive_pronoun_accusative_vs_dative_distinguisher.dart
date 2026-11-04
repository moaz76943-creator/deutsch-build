/// Task 1353: Disambiguates reflexive pronouns (mich vs mir)
class ReflexivePronounDistinguisher {
  String getReflexive(bool hasDirectObject) => hasDirectObject ? 'mir' : 'mich';
}
