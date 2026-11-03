/// Task 1245: Enforces minimum leading/trailing characters per hyphenated line
class HyphenationMinLeadTrailGuard {
  static const int minLead = 2;
  static const int minTrail = 3;
  bool isSplitPermissible(int prefixLen, int suffixLen) => prefixLen >= minLead && suffixLen >= minTrail;
}
