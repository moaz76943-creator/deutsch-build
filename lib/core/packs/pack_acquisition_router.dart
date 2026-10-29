import 'pack_models.dart';

export 'pack_models.dart';

final class PackAcquisitionRouter {
  PackAcquisitionRouter({
    required LocalPackCatalog storage,
    List<PackAcquisitionProvider> providers =
        const <PackAcquisitionProvider>[],
  })  : _storage = storage,
        _providers = List<PackAcquisitionProvider>.unmodifiable(
          _validateProviders(providers),
        );

  final LocalPackCatalog _storage;
  final List<PackAcquisitionProvider> _providers;

  Future<PackRouteDecision> route(PackPairRequest request) async {
    request.pairKey;
    final local = await _storage.find(request);
    if (local != null) {
      return PackRouteDecision(
        request: request,
        availability: PackAvailabilityStatus.available,
        status: PackAcquisitionStatus.localReady,
        localPack: local,
        providerCandidates: const <String>[],
      );
    }

    return PackRouteDecision(
      request: request,
      availability: PackAvailabilityStatus.missing,
      status: PackAcquisitionStatus.requiresDownload,
      localPack: null,
      providerCandidates: List<String>.unmodifiable(
        _providers.map((provider) => provider.id),
      ),
    );
  }

  Future<void> acquire(PackPairRequest request) async {
    request.pairKey;
    throw StateError(
      'pack_acquisition_disabled_offline_phase14',
    );
  }

  static List<PackAcquisitionProvider> _validateProviders(
    List<PackAcquisitionProvider> providers,
  ) {
    final ids = <String>{};
    for (final provider in providers) {
      final id = provider.id.trim().toLowerCase();
      if (id.isEmpty ||
          id.length > 80 ||
          !RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$')
              .hasMatch(id)) {
        throw ArgumentError.value(
          provider.id,
          'provider.id',
          'must be a stable provider token',
        );
      }
      if (!ids.add(id)) {
        throw ArgumentError(
          'Duplicate pack acquisition provider: $id',
        );
      }
    }
    return providers;
  }
}
