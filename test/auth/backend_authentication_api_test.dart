import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/account_session.dart';
import '../../lib/models/backend_authentication_api.dart';
import '../../lib/models/backend_authentication_contract.dart';
import '../../lib/models/backend_transport.dart';
import '../../lib/services/backend_authentication_api.dart';
import '../../lib/services/backend_transport.dart';

class FakeTransport implements BackendTransport {
  BackendTransportRequest? request;

  @override
  Future<BackendTransportResponse> send(BackendTransportRequest request) async {
    this.request = request;
    return const BackendTransportResponse();
  }
}

void main() {
  test('maps Email OTP verification API request to transport', () async {
    final transport = FakeTransport();
    final api = BackendAuthenticationApi(transport);

    await api.send(
      const BackendAuthenticationApiRequest.verifyEmailOtp(
        email: 'a@example.com',
        otp: '123456',
      ),
    );

    expect(
      transport.request?.operation,
      BackendTransportOperation.verifyEmailOtp,
    );
    expect(transport.request?.email, 'a@example.com');
    expect(transport.request?.otp, '123456');
  });

  test('maps provider authentication API request to transport', () async {
    final transport = FakeTransport();
    final api = BackendAuthenticationApi(transport);
    const assertion = ProviderAuthenticationAssertion(
      provider: AccountProvider.google,
      assertion: 'ephemeral',
    );

    await api.send(
      const BackendAuthenticationApiRequest.authenticateProvider(
        assertion: assertion,
      ),
    );

    expect(
      transport.request?.operation,
      BackendTransportOperation.authenticateProvider,
    );
    expect(transport.request?.assertion, assertion);
  });

  test('returns transport session without changing its shape', () async {
    const session = AccountSession.authenticated(
      identity: AccountIdentity(userId: 'u1'),
    );
    final transport = _SessionTransport(session);

    final response = await BackendAuthenticationApi(transport)
        .send(const BackendAuthenticationApiRequest.currentSession());

    expect(response.session, session);
  });
}

class _SessionTransport implements BackendTransport {
  const _SessionTransport(this.session);

  final AccountSession session;

  @override
  Future<BackendTransportResponse> send(
    BackendTransportRequest request,
  ) async => BackendTransportResponse(session: session);
}
