/// Task 1367: PP-attachment disambiguation scorer (Noun vs Verb)
class PpAttachmentScorer {
  bool attachesToVerb(double verbAssociation, double nounAssociation) => verbAssociation > nounAssociation;
}
