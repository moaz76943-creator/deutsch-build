import '../models/account_session.dart';
import 'authentication.dart';
import '../models/backend_authentication_contract.dart';

/// Fail-closed Email OTP adapter used until a production backend contract is
/// selected and integrated. It stores no OTP or credential material.
final class UnavailableEmailOtpProvider implements EmailOtpProvider {
  const UnavailableEmailOtpProvider();

  @override
  Future<void> requestCode({required String email}) async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> verifyCode({
    required String email,
    required String otp,
  }) async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }
}

/// Fail-closed social adapter used until the selected platform SDK and
/// backend exchange are integrated.
final class UnavailableSocialAuthenticationProvider
    implements SocialAuthenticationProvider {
  const UnavailableSocialAuthenticationProvider(this.provider);

  @override
  final AccountProvider provider;

  @override
  Future<ProviderAuthenticationAssertion> authenticate() async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }
}
