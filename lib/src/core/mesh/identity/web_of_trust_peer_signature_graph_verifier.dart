/// Task 1544: Web-of-Trust decentralized peer signature graph verifier
class WebOfTrustVerifier {
  double computeTrustScore(int mutualEndorsements) => (mutualEndorsements / 5.0).clamp(0.0, 1.0);
}
