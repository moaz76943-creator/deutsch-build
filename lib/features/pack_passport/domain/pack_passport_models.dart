import '../../../core/pack_acquisition/hybrid_pad_models.dart';
import '../../../core/packs/pack_models.dart';

enum PackPassportInstallState {
  notInstalled,
  partial,
  installed,
}

enum PackPassportVerificationStatus {
  unverified,
  verified,
  blocked,
}

final class PackPassportLogicalState {
  PackPassportLogicalState({
    required this.logicalPackId,
    required this.installed,
    required this.storageBytes,
    required String version,
    required this.schemaVersion,
    required String sha256,
    required this.verified,
    this.failureReason,
  })  : version = version.trim(),
        sha256 = sha256.trim().toLowerCase() {
    if (logicalPackId.trim().isEmpty) {
      throw ArgumentError.value(
        logicalPackId,
        'logicalPackId',
        'must not be empty',
      );
    }
    if (storageBytes < 0) {
      throw ArgumentError.value(
        storageBytes,
        'storageBytes',
        'must not be negative',
      );
    }
    if (this.version.isEmpty) {
      throw ArgumentError.value(version, 'version', 'must not be empty');
    }
    if (schemaVersion < 1) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'must be positive',
      );
    }
    if (!RegExp(r'^[a-f0-9]{64}

abstract interface class PackPassportLogicalStateSource {
  Future<PackPassportLogicalState?> stateFor(String logicalPackId);
}

final class PackPassportEntry {
  PackPassportEntry({
    required this.request,
    required this.installState,
    required this.offlineReady,
    required this.requiredComponentCount,
    required this.installedComponentCount,
    required this.expectedSizeBytes,
    required this.installedSizeBytes,
    required this.versionSummary,
    required this.verificationStatus,
    required Iterable<String> logicalPackIds,
    required Iterable<String> physicalShardIds,
    this.blockReason,
  })  : logicalPackIds = List<String>.unmodifiable(logicalPackIds),
        physicalShardIds = List<String>.unmodifiable(physicalShardIds);

  final PackPairRequest request;
  final PackPassportInstallState installState;
  final bool offlineReady;
  final int requiredComponentCount;
  final int installedComponentCount;
  final int expectedSizeBytes;
  final int installedSizeBytes;
  final String versionSummary;
  final PackPassportVerificationStatus verificationStatus;
  final List<String> logicalPackIds;
  final List<String> physicalShardIds;
  final String? blockReason;

  String get pairKey => request.pairKey;
}

final class PackPassportAssembler {
  const PackPassportAssembler({
    required this.catalog,
    required this.stateSource,
  });

  final HybridPadCatalog catalog;
  final PackPassportLogicalStateSource stateSource;

  Future<PackPassportEntry> build(PackPairRequest request) async {
    final requirements = catalog.requirementsFor(request);
    final states = <PackPassportLogicalState?>[];

    for (final descriptor in requirements) {
      states.add(await stateSource.stateFor(descriptor.id));
    }

    var installedCount = 0;
    var installedSizeBytes = 0;
    var allVerified = true;
    String? blockReason;

    for (var index = 0; index < requirements.length; index += 1) {
      final state = states[index];
      if (state == null || !state.installed) {
        allVerified = false;
        continue;
      }

      installedCount += 1;
      installedSizeBytes += state.storageBytes;

      final descriptor = requirements[index];
      final descriptorMatches =
          state.logicalPackId == descriptor.id &&
          state.version == descriptor.version &&
          state.schemaVersion == descriptor.schemaVersion &&
          state.sha256 == descriptor.sha256;
      if (!state.verified || !descriptorMatches) {
        allVerified = false;
      }
      if (!descriptorMatches && blockReason == null) {
        blockReason =
            'Installed logical pack does not match the active descriptor: '
            '${descriptor.id}';
      }
      if (blockReason == null &&
          state.failureReason != null &&
          state.failureReason!.trim().isNotEmpty) {
        blockReason = state.failureReason!.trim();
      }
    }

    final installState = installedCount == 0
        ? PackPassportInstallState.notInstalled
        : installedCount == requirements.length
            ? PackPassportInstallState.installed
            : PackPassportInstallState.partial;

    final verificationStatus = blockReason != null
        ? PackPassportVerificationStatus.blocked
        : allVerified && installState == PackPassportInstallState.installed
            ? PackPassportVerificationStatus.verified
            : PackPassportVerificationStatus.unverified;

    final offlineReady =
        installState == PackPassportInstallState.installed &&
            verificationStatus == PackPassportVerificationStatus.verified;

    final versions = <String>{};
    for (var index = 0; index < requirements.length; index += 1) {
      final state = states[index];
      final version = state?.version.trim();
      versions.add(
        version == null || version.isEmpty
            ? requirements[index].version
            : version,
      );
    }

    final physicalShardIds = requirements
        .map((descriptor) => catalog.shardForLogicalPack(descriptor.id).id)
        .toSet()
        .toList(growable: false)
      ..sort();

    return PackPassportEntry(
      request: request,
      installState: installState,
      offlineReady: offlineReady,
      requiredComponentCount: requirements.length,
      installedComponentCount: installedCount,
      expectedSizeBytes: requirements.fold<int>(
        0,
        (total, descriptor) => total + descriptor.sizeBytes,
      ),
      installedSizeBytes: installedSizeBytes,
      versionSummary: versions.length == 1
          ? versions.single
          : (versions.toList(growable: false)..sort()).join(' + '),
      verificationStatus: verificationStatus,
      logicalPackIds: requirements.map((descriptor) => descriptor.id),
      physicalShardIds: physicalShardIds,
      blockReason: blockReason,
    );
  }
}
).hasMatch(this.sha256)) {
      throw ArgumentError.value(
        sha256,
        'sha256',
        'must be a SHA-256 hex digest',
      );
    }
  }

  final String logicalPackId;
  final bool installed;
  final int storageBytes;
  final String version;
  final int schemaVersion;
  final String sha256;
  final bool verified;
  final String? failureReason;
}

abstract interface class PackPassportLogicalStateSource {
  Future<PackPassportLogicalState?> stateFor(String logicalPackId);
}

final class PackPassportEntry {
  PackPassportEntry({
    required this.request,
    required this.installState,
    required this.offlineReady,
    required this.requiredComponentCount,
    required this.installedComponentCount,
    required this.expectedSizeBytes,
    required this.installedSizeBytes,
    required this.versionSummary,
    required this.verificationStatus,
    required Iterable<String> logicalPackIds,
    required Iterable<String> physicalShardIds,
    this.blockReason,
  })  : logicalPackIds = List<String>.unmodifiable(logicalPackIds),
        physicalShardIds = List<String>.unmodifiable(physicalShardIds);

  final PackPairRequest request;
  final PackPassportInstallState installState;
  final bool offlineReady;
  final int requiredComponentCount;
  final int installedComponentCount;
  final int expectedSizeBytes;
  final int installedSizeBytes;
  final String versionSummary;
  final PackPassportVerificationStatus verificationStatus;
  final List<String> logicalPackIds;
  final List<String> physicalShardIds;
  final String? blockReason;

  String get pairKey => request.pairKey;
}

final class PackPassportAssembler {
  const PackPassportAssembler({
    required this.catalog,
    required this.stateSource,
  });

  final HybridPadCatalog catalog;
  final PackPassportLogicalStateSource stateSource;

  Future<PackPassportEntry> build(PackPairRequest request) async {
    final requirements = catalog.requirementsFor(request);
    final states = <PackPassportLogicalState?>[];

    for (final descriptor in requirements) {
      states.add(await stateSource.stateFor(descriptor.id));
    }

    var installedCount = 0;
    var installedSizeBytes = 0;
    var allVerified = true;
    String? blockReason;

    for (var index = 0; index < requirements.length; index += 1) {
      final state = states[index];
      if (state == null || !state.installed) {
        allVerified = false;
        continue;
      }

      installedCount += 1;
      installedSizeBytes += state.storageBytes;
      if (!state.verified) {
        allVerified = false;
      }
      if (blockReason == null &&
          state.failureReason != null &&
          state.failureReason!.trim().isNotEmpty) {
        blockReason = state.failureReason!.trim();
      }
    }

    final installState = installedCount == 0
        ? PackPassportInstallState.notInstalled
        : installedCount == requirements.length
            ? PackPassportInstallState.installed
            : PackPassportInstallState.partial;

    final verificationStatus = blockReason != null
        ? PackPassportVerificationStatus.blocked
        : allVerified && installState == PackPassportInstallState.installed
            ? PackPassportVerificationStatus.verified
            : PackPassportVerificationStatus.unverified;

    final offlineReady =
        installState == PackPassportInstallState.installed &&
            verificationStatus == PackPassportVerificationStatus.verified;

    final versions = <String>{};
    for (var index = 0; index < requirements.length; index += 1) {
      final state = states[index];
      final version = state?.version.trim();
      versions.add(
        version == null || version.isEmpty
            ? requirements[index].version
            : version,
      );
    }

    final physicalShardIds = requirements
        .map((descriptor) => catalog.shardForLogicalPack(descriptor.id).id)
        .toSet()
        .toList(growable: false)
      ..sort();

    return PackPassportEntry(
      request: request,
      installState: installState,
      offlineReady: offlineReady,
      requiredComponentCount: requirements.length,
      installedComponentCount: installedCount,
      expectedSizeBytes: requirements.fold<int>(
        0,
        (total, descriptor) => total + descriptor.sizeBytes,
      ),
      installedSizeBytes: installedSizeBytes,
      versionSummary: versions.length == 1
          ? versions.single
          : (versions.toList(growable: false)..sort()).join(' + '),
      verificationStatus: verificationStatus,
      logicalPackIds: requirements.map((descriptor) => descriptor.id),
      physicalShardIds: physicalShardIds,
      blockReason: blockReason,
    );
  }
}
