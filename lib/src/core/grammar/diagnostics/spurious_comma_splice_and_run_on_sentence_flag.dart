/// Task 1345: Identifies comma splices and missing conjunctions
class CommaSpliceFlag {
  bool isCommaSplice(bool hasComma, bool hasConjunction) => hasComma && !hasConjunction;
}
