enum PackAvailabilityStatus {
  available,
  missing,
}

enum PackAcquisitionStatus {
  localReady,
  requiresDownload,
}

final class PackPairRequest {
  const PackPairRequest({
    required this.sourceLanguageTag,
    required this.targetLanguageTag,
  });

  final String sourceLanguageTag;
  final String targetLanguageTag;

  String get source => _language(sourceLanguageTag, 'sourceLanguageTag');
  String get target => _language(targetLanguageTag, 'targetLanguageTag');

  String get pairKey {
    final normalizedSource = source;
    final normalizedTarget = target;
    if (normalizedSource == normalizedTarget) {
      throw ArgumentError(
        'Source and target language must be different.',
      );
    }
    return '$normalizedSource->$normalizedTarget';
  }

  String get storageKey =>
      '${source.replaceAll('-', '_')}__${target.replaceAll('-', '_')}';
}

abstract interface class LocalPackReader {
  Future<String> readText(String relativePath);
  Future<List<int>> readBytes(String relativePath);
  Future<List<String>> listAssets();
}

final class LocalPackHandle {
  const LocalPackHandle({
    required this.pairKey,
    required this.rootPath,
    required this.reader,
    required this.hasJsonContent,
    required this.hasSqliteContent,
  });

  final String pairKey;
  final String rootPath;
  final LocalPackReader reader;
  final bool hasJsonContent;
  final bool hasSqliteContent;
}

abstract interface class LocalPackCatalog {
  Future<LocalPackHandle?> find(PackPairRequest request);
}

abstract interface class PackAcquisitionProvider {
  String get id;
  bool get requiresNetwork;

  Future<void> acquire(PackPairRequest request);
}

final class PackRouteDecision {
  const PackRouteDecision({
    required this.request,
    required this.availability,
    required this.status,
    required this.localPack,
    required this.providerCandidates,
  });

  final PackPairRequest request;
  final PackAvailabilityStatus availability;
  final PackAcquisitionStatus status;
  final LocalPackHandle? localPack;
  final List<String> providerCandidates;
}

String _language(String raw, String field) {
  final normalized =
      raw.trim().replaceAll('_', '-').toLowerCase();
  if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
      .hasMatch(normalized)) {
    throw ArgumentError.value(
      raw,
      field,
      'must be a valid language tag',
    );
  }
  return normalized;
}
