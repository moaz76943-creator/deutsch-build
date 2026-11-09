import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// Exception thrown when outbound network access is attempted without consent
/// or while offline-first sovereign mode is active.
class NetworkAccessDeniedException implements Exception {
  final String message;
  final String destinationUri;
  final DateTime timestamp;

  NetworkAccessDeniedException(this.message, {required this.destinationUri})
      : timestamp = DateTime.now().toUtc();

  @override
  String toString() =>
      'NetworkAccessDeniedException: $message [URI: $destinationUri, UTC: $timestamp]';
}

/// Hardened cloud storage client enforcing strict offline sovereignty and airgap rules.
class HttpCloudStorageService {
  final bool _offlineModeEnforced;
  final bool _userSyncConsentGranted;
  final Map<String, Uint8List> _localStorageCache = <String, Uint8List>{};

  HttpCloudStorageService({
    bool offlineModeEnforced = true,
    bool userSyncConsentGranted = false,
  })  : _offlineModeEnforced = offlineModeEnforced,
        _userSyncConsentGranted = userSyncConsentGranted;

  bool get isOfflineModeActive => _offlineModeEnforced;
  bool get hasUserSyncConsent => _userSyncConsentGranted;

  /// Guard outbound requests against unauthorized data egress.
  void _assertOutboundPermitted(String endpoint) {
    if (_offlineModeEnforced) {
      throw NetworkAccessDeniedException(
        'Outbound network access blocked: Platform is in Offline Sovereign Airgap Mode.',
        destinationUri: endpoint,
      );
    }
    if (!_userSyncConsentGranted) {
      throw NetworkAccessDeniedException(
        'Outbound network access blocked: User synchronization consent not granted.',
        destinationUri: endpoint,
      );
    }
  }

  /// Store pack in local sovereign cache without network call.
  Future<void> storeLocalPack(String packId, Uint8List bytes) async {
    _localStorageCache[packId] = Uint8List.fromList(bytes);
  }

  /// Retrieve pack from local sovereign cache.
  Future<Uint8List?> getLocalPack(String packId) async {
    final cached = _localStorageCache[packId];
    return cached != null ? Uint8List.fromList(cached) : null;
  }

  /// Remote upload attempt guarded by sovereign airgap assertion.
  Future<bool> uploadPackTelemetry(String endpoint, Map<String, dynamic> telemetry) async {
    _assertOutboundPermitted(endpoint);
    // Real outbound network call only reachable if consent is true and offline is false
    return true;
  }

  int get localCachedPacksCount => _localStorageCache.length;
}
