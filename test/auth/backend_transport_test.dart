import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/account_session.dart';
import '../../lib/models/backend_authentication_contract.dart';
import '../../lib/models/backend_transport.dart';
import '../../lib/services/authentication.dart';
import '../../lib/services/backend_transport.dart';

class FakeTransport implements BackendTransport {
  FakeTransport({this.response = const BackendTransportResponse()});

  final BackendTransportResponse response;
  BackendTransportRequest? request;
  BackendTransportFailureCode? failure;

  @override
  Future<BackendTransportResponse> send(BackendTransportRequest request) async {
    this.request = request;
    final code = failure;
    if (code != null) throw BackendTransportFailure(code);
    return response;
  }
}

void main() {
  test('transport request carries operation and transient input only', () {
    const request = BackendTransportRequest.verifyEmailOtp(
      email: 'a@example.com',
      otp: '123456',
    );
    expect(request.operation, BackendTransportOperation.verifyEmailOtp);
    expect(request.email, 'a@example.com');
    expect(request.otp, '123456');
    expect(request.assertion, isNull);
  });

  test('transport gateway maps backend failure categories', () async {
    final transport = FakeTransport()
      ..failure = BackendTransportFailureCode.rateLimited;
    final gateway = TransportBackendAuthenticationGateway(transport);

    expect(
      gateway.requestEmailOtp(const EmailOtpRequest(email: 'a@example.com')),
      throwsA(
        isA<AuthenticationFailure>().having(
          (error) => error.code,
          'code',
          AuthenticationFailureCode.rateLimited,
        ),
      ),
    );
  });

  test('provider authentication response must contain a session', () async {
    final transport = FakeTransport();
    final gateway = TransportBackendAuthenticationGateway(transport);

    expect(
      gateway.authenticateProvider(
        const ProviderAuthenticationAssertion(
          provider: AccountProvider.google,
          assertion: 'ephemeral',
        ),
      ),
      throwsA(isA<AuthenticationFailure>()),
    );
  });

  test('unavailable transport fails closed', () async {
    const transport = UnavailableBackendTransport();
    expect(
      transport.send(const BackendTransportRequest.currentSession()),
      throwsA(isA<BackendTransportFailure>()),
    );
  });
}
