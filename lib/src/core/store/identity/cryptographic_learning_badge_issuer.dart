class CryptographicLearningBadgeIssuer {
  Map<String, dynamic> issueBadge(String did, String cefrLevel) =>
      {'recipient': did, 'level': cefrLevel, 'signature': 'signed_by_local_key'};
}
