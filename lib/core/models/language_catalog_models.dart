import '../packs/pack_models.dart';

final class LanguageMetadata {
  const LanguageMetadata({
    required this.id,
    required this.name,
    required this.isRtl,
  });

  final String id;
  final String name;
  final bool isRtl;
}

final class ResolvedLanguagePair {
  const ResolvedLanguagePair({
    required this.source,
    required this.target,
    required this.pairKey,
    required this.generation,
    required this.route,
  });

  final LanguageMetadata source;
  final LanguageMetadata target;
  final String pairKey;
  final int generation;
  final PackRouteDecision route;

  bool get isLocallyReady =>
      route.status == PackAcquisitionStatus.localReady;

  bool get requiresDownload =>
      route.status == PackAcquisitionStatus.requiresDownload;
}
