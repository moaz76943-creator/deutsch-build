import '../models/backend_transport.dart';

final class BackendTransportFailure implements Exception {
  const BackendTransportFailure(this.code);

  final BackendTransportFailureCode code;

  @override
  String toString() => 'BackendTransportFailure($code)';
}

/// Platform-neutral backend transport. It does not know about learner state,
/// subscriptions, provider SDKs, or persistence.
abstract interface class BackendTransport {
  Future<BackendTransportResponse> send(BackendTransportRequest request);
}

/// Safe default until a real backend transport is deliberately selected.
final class UnavailableBackendTransport implements BackendTransport {
  const UnavailableBackendTransport();

  @override
  Future<BackendTransportResponse> send(BackendTransportRequest request) async {
    throw const BackendTransportFailure(
      BackendTransportFailureCode.unavailable,
    );
  }
}
