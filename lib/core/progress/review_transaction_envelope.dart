class ReviewTransactionEnvelope {
  final String reviewEventId;
  final String learnerContentKey;
  final int rating;
  final DateTime timestamp;
  final String languagePairKey;

  const ReviewTransactionEnvelope({
    required this.reviewEventId,
    required this.learnerContentKey,
    required this.rating,
    required this.timestamp,
    required this.languagePairKey,
  });

  Map<String, dynamic> toMap() => {
        'reviewEventId': reviewEventId,
        'learnerContentKey': learnerContentKey,
        'rating': rating,
        'timestamp': timestamp.toIso8601String(),
        'languagePairKey': languagePairKey,
      };
}
