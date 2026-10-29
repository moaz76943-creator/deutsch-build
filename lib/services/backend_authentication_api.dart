import '../models/backend_authentication_api.dart';
import '../models/backend_transport.dart';
import 'backend_transport.dart';

/// Maps semantic authentication API operations onto the provider-neutral
/// transport contract. It introduces no network implementation.
final class BackendAuthenticationApi {
  const BackendAuthenticationApi(this.transport);

  final BackendTransport transport;

  Future<BackendAuthenticationApiResponse> send(
    BackendAuthenticationApiRequest request,
  ) async {
    final response = await transport.send(_toTransportRequest(request));
    return BackendAuthenticationApiResponse(
      session: response.session,
      credentials: response.credentials,
    );
  }

  static T _require<T>(T? value, String field) {
    final result = value;
    if (result == null) {
      throw ArgumentError('Missing $field for authentication operation');
    }
    return result;
  }

  static BackendTransportRequest _toTransportRequest(
    BackendAuthenticationApiRequest request,
  ) {
    return switch (request.operation) {
      BackendAuthenticationOperation.requestEmailOtp =>
        BackendTransportRequest.requestEmailOtp(
          email: _require(request.email, 'email'),
        ),
      BackendAuthenticationOperation.verifyEmailOtp =>
        BackendTransportRequest.verifyEmailOtp(
          email: _require(request.email, 'email'),
          otp: _require(request.otp, 'otp'),
        ),
      BackendAuthenticationOperation.authenticateProvider =>
        BackendTransportRequest.authenticateProvider(
          assertion: _require(request.assertion, 'assertion'),
        ),
      BackendAuthenticationOperation.currentSession =>
        BackendTransportRequest.currentSession(
          credentials: request.credentials,
        ),
      BackendAuthenticationOperation.renewSession =>
        BackendTransportRequest.renewSession(
          credentials: _require(request.credentials, 'credentials'),
        ),
      BackendAuthenticationOperation.revokeSession =>
        BackendTransportRequest.revokeSession(credentials: request.credentials),
      BackendAuthenticationOperation.signOut =>
        const BackendTransportRequest.signOut(),
    };
  }
}
