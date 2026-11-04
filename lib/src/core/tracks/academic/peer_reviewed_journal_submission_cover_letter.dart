class PeerReviewedJournalSubmissionCoverLetter {
  const PeerReviewedJournalSubmissionCoverLetter();
  String letterOpening(String editor, String journal, String lang) =>
      lang == 'ar' ? 'سعادة رئيس تحرير مجلة $journal، يسرنا تقديم مخطوطتنا البحثية...' : 'Dear Editor of $journal, we are pleased to submit our manuscript...';
}
