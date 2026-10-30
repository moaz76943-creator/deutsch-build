class CacheIdentity {
  final String language; // e.g. en
  final String direction; // e.g. en_es
  final int pairEpoch;
  final String contentVersion;

  const CacheIdentity({
    required this.language,
    required this.direction,
    required this.pairEpoch,
    required this.contentVersion,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheIdentity &&
        other.language == language &&
        other.direction == direction &&
        other.pairEpoch == pairEpoch &&
        other.contentVersion == contentVersion;
  }

  @override
  int get hashCode => Object.hash(language, direction, pairEpoch, contentVersion);

  @override
  String toString() {
    return 'CacheIdentity(language: $language, direction: $direction, pairEpoch: $pairEpoch, contentVersion: $contentVersion)';
  }
}
