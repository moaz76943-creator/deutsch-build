/// Task 1301: Universal Dependencies 17 POS tag classifier
enum UniversalPos { noun, verb, adj, adv, pron, det, adp, num, conj, cconj, sconj, part, intj, propn, aux, sym, punct, x }
class UniversalPosClassifier {
  UniversalPos tagToken(String token) => token.endsWith('en') ? UniversalPos.verb : UniversalPos.noun;
}
