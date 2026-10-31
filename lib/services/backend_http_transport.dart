import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/account_session.dart';
import '../models/backend_transport.dart';
import '../models/secure_session_credentials.dart';
import 'backend_transport.dart';

/// HTTPS transport implementation for the provider-neutral backend contract.
///
/// This class owns only transient wire encoding/decoding and network I/O. It
/// never persists credentials, interprets credential contents, or decides
/// authentication/entitlement policy.
final class HttpBackendTransport implements BackendTransport {
  HttpBackendTransport(
    this.baseUri, {
    Duration timeout = const Duration(seconds: 15),
  }) : timeout = _validateTimeout(timeout);

  static const int MAX_REQUEST_BYTES = 32 * 1024;
  static const int MAX_RESPONSE_BYTES = 64 * 1024;
  static const Duration MIN_TIMEOUT = Duration(seconds: 1);
  static const Duration MAX_TIMEOUT = Duration(seconds: 30);

  final Uri baseUri;
  final Duration timeout;

  @override
  Future<BackendTransportResponse> send(BackendTransportRequest request) async {
    _validateBaseUri(baseUri);

    final body = utf8.encode(jsonEncode(_requestJson(request)));
    if (body.length > MAX_REQUEST_BYTES) {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.unavailable,
      );
    }

    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final uri = baseUri.resolve('v1/auth/${request.operation.name}');
      final requestMessage = await client.postUrl(uri).timeout(timeout);
      requestMessage.headers.contentType = ContentType.json;
      requestMessage.headers.contentLength = body.length;
      requestMessage.add(body);

      final response = await requestMessage.close().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _failureForStatus(response.statusCode, request.operation);
      }

      final responseDeadline = DateTime.now().add(timeout);
      final responseBytes = await _readResponseBytes(
        response,
        responseDeadline,
      );

      if (responseBytes.isEmpty) {
        return const BackendTransportResponse();
      }

      final decoded = jsonDecode(utf8.decode(responseBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const BackendTransportFailure(
          BackendTransportFailureCode.unavailable,
        );
      }
      final parsedResponse = _responseFromJson(decoded);
      _validateResponseForOperation(parsedResponse, request.operation);
      return parsedResponse;
    } on BackendTransportFailure {
      rethrow;
    } on TimeoutException {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.unavailable,
      );
    } on SocketException {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.unavailable,
      );
    } on FormatException {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.unavailable,
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<List<int>> _readResponseBytes(
    HttpClientResponse response,
    DateTime responseDeadline,
  ) async {
    final responseBytes = <int>[];
    final iterator = StreamIterator<List<int>>(response);
    try {
      while (await iterator.moveNext().timeout(
            _remainingUntil(responseDeadline),
          )) {
        responseBytes.addAll(iterator.current);
        if (responseBytes.length > MAX_RESPONSE_BYTES) {
          throw const BackendTransportFailure(
            BackendTransportFailureCode.unavailable,
          );
        }
      }
      return responseBytes;
    } finally {
      await iterator.cancel();
    }
  }

  static Duration _remainingUntil(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      throw TimeoutException('Backend response deadline exceeded');
    }
    return remaining;
  }

  static Map<String, dynamic> _requestJson(BackendTransportRequest request) {
    final result = <String, dynamic>{'operation': request.operation.name};
    if (request.email != null) result['email'] = request.email;
    if (request.otp != null) result['otp'] = request.otp;
    final assertion = request.assertion;
    if (assertion != null) {
      result['provider'] = assertion.provider.name;
      result['assertion'] = assertion.assertion;
    }
    final credentials = request.credentials;
    if (credentials != null) {
      result['credential'] = credentials.value;
    }
    return result;
  }

  static BackendTransportResponse _responseFromJson(Map<String, dynamic> json) {
    SecureSessionCredentials? credentials;
    final credential = json['credential'];
    if (credential != null) {
      if (credential is! String) {
        throw const BackendTransportFailure(
          BackendTransportFailureCode.unavailable,
        );
      }
      try {
        credentials = SecureSessionCredentials(credential);
      } on ArgumentError {
        throw const BackendTransportFailure(
          BackendTransportFailureCode.invalidSession,
        );
      }
    }

    AccountSession? session;
    final rawSession = json['session'];
    if (rawSession != null) {
      if (rawSession is! Map<String, dynamic>) {
        throw const BackendTransportFailure(
          BackendTransportFailureCode.unavailable,
        );
      }
      session = _sessionFromJson(rawSession);
    }

    return BackendTransportResponse(session: session, credentials: credentials);
  }

  static void _validateResponseForOperation(
    BackendTransportResponse response,
    BackendTransportOperation operation,
  ) {
    switch (operation) {
      case BackendTransportOperation.verifyEmailOtp:
      case BackendTransportOperation.authenticateProvider:
        if (response.session == null || response.credentials == null) {
          throw const BackendTransportFailure(
            BackendTransportFailureCode.invalidSession,
          );
        }
      case BackendTransportOperation.currentSession:
        if (response.session == null) {
          throw const BackendTransportFailure(
            BackendTransportFailureCode.invalidSession,
          );
        }
      case BackendTransportOperation.renewSession:
        if (response.session == null || response.credentials == null) {
          throw const BackendTransportFailure(
            BackendTransportFailureCode.invalidSession,
          );
        }
      case BackendTransportOperation.requestEmailOtp:
      case BackendTransportOperation.revokeSession:
      case BackendTransportOperation.signOut:
        break;
    }
  }

  static AccountSession _sessionFromJson(Map<String, dynamic> json) {
    final isAuthenticated = json['isAuthenticated'];
    if (isAuthenticated is! bool) {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.unavailable,
      );
    }
    if (!isAuthenticated) {
      return const AccountSession.unauthenticated();
    }

    final rawUserId = json['userId'];
    if (rawUserId is! String || rawUserId.trim().isEmpty) {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.invalidSession,
      );
    }

    final rawExpiresAt = json['expiresAt'];
    if (rawExpiresAt == null || rawExpiresAt is! String) {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.invalidSession,
      );
    }

    late final DateTime expiresAt;
    try {
      expiresAt = DateTime.parse(rawExpiresAt).toUtc();
    } on FormatException {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.invalidSession,
      );
    }
    if (!DateTime.now().toUtc().isBefore(expiresAt)) {
      throw const BackendTransportFailure(
        BackendTransportFailureCode.invalidSession,
      );
    }

    return AccountSession.authenticated(
      identity: AccountIdentity(userId: rawUserId),
      expiresAt: expiresAt,
    );
  }

  static BackendTransportFailure _failureForStatus(
    int statusCode,
    BackendTransportOperation operation,
  ) {
    if (statusCode == 429) {
      return const BackendTransportFailure(
        BackendTransportFailureCode.rateLimited,
      );
    }
    if (statusCode == 408 || statusCode >= 500) {
      return const BackendTransportFailure(
        BackendTransportFailureCode.retryable,
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      final sessionOperation =
          operation == BackendTransportOperation.currentSession ||
              operation == BackendTransportOperation.renewSession ||
              operation == BackendTransportOperation.revokeSession;
      return BackendTransportFailure(
        sessionOperation
            ? BackendTransportFailureCode.invalidSession
            : BackendTransportFailureCode.invalidAuthentication,
      );
    }
    return const BackendTransportFailure(
      BackendTransportFailureCode.invalidAuthentication,
    );
  }

  static Duration _validateTimeout(Duration value) {
    if (value < MIN_TIMEOUT || value > MAX_TIMEOUT) {
      throw ArgumentError(
        'Backend transport timeout must be between 1 and 30 seconds',
      );
    }
    return value;
  }

  static void _validateBaseUri(Uri uri) {
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      throw ArgumentError('Backend transport requires an HTTPS base URI');
    }
  }
}
