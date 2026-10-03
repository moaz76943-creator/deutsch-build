import 'dart:convert';

enum InputFailureCode {
  invalidJson,
  nonObjectJson,
  payloadTooLarge,
  maxDepthExceeded,
}

final class InputFailure {
  const InputFailure({
    required this.code,
    required this.message,
  });

  final InputFailureCode code;
  final String message;
}

final class JsonObjectResult {
  const JsonObjectResult._({
    this.value,
    this.failure,
  });

  const JsonObjectResult.success(Map<String, Object?> value)
      : this._(value: value);

  const JsonObjectResult.failure(InputFailure failure)
      : this._(failure: failure);

  final Map<String, Object?>? value;
  final InputFailure? failure;

  bool get isSuccess => failure == null;
}

enum ApiFailureCode {
  insecureScheme,
  hostNotAllowed,
  methodNotAllowed,
  payloadTooLarge,
}

final class ApiFailure {
  const ApiFailure({
    required this.code,
    required this.message,
  });

  final ApiFailureCode code;
  final String message;
}

final class ApiValidationResult {
  const ApiValidationResult(this.failures);

  final List<ApiFailure> failures;

  bool get isValid => failures.isEmpty;
}

final class ApiRequestPolicy {
  const ApiRequestPolicy({
    required this.allowedHosts,
    this.allowedMethods = const <String>{'GET'},
    this.maxBodyBytes = 1024 * 1024,
  });

  final Set<String> allowedHosts;
  final Set<String> allowedMethods;
  final int maxBodyBytes;
}

final class SafeInputValidator {
  const SafeInputValidator();

  JsonObjectResult decodeJsonObject(
    String raw, {
    int maxBytes = 64 * 1024,
    int maxDepth = 16,
  }) {
    if (utf8.encode(raw).length > maxBytes) {
      return const JsonObjectResult.failure(
        InputFailure(
          code: InputFailureCode.payloadTooLarge,
          message: 'JSON payload exceeds the configured byte limit.',
        ),
      );
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const JsonObjectResult.failure(
        InputFailure(
          code: InputFailureCode.invalidJson,
          message: 'Input is not valid JSON.',
        ),
      );
    }

    if (decoded is! Map<String, Object?>) {
      return const JsonObjectResult.failure(
        InputFailure(
          code: InputFailureCode.nonObjectJson,
          message: 'JSON root must be an object.',
        ),
      );
    }

    if (_depth(decoded) > maxDepth) {
      return const JsonObjectResult.failure(
        InputFailure(
          code: InputFailureCode.maxDepthExceeded,
          message: 'JSON nesting exceeds the configured depth limit.',
        ),
      );
    }

    return JsonObjectResult.success(
      Map<String, Object?>.unmodifiable(decoded),
    );
  }

  ApiValidationResult validateApiRequest(
    Uri uri, {
    required String method,
    required ApiRequestPolicy policy,
    int bodyBytes = 0,
  }) {
    final failures = <ApiFailure>[];
    final normalizedMethod = method.trim().toUpperCase();

    if (uri.scheme.toLowerCase() != 'https') {
      failures.add(
        const ApiFailure(
          code: ApiFailureCode.insecureScheme,
          message: 'Only HTTPS endpoints are allowed.',
        ),
      );
    }

    final normalizedHost = uri.host.toLowerCase();
    final allowedHosts = policy.allowedHosts
        .map((host) => host.toLowerCase())
        .toSet();
    if (!allowedHosts.contains(normalizedHost)) {
      failures.add(
        ApiFailure(
          code: ApiFailureCode.hostNotAllowed,
          message: 'Host "' + normalizedHost + '" is not allowlisted.',
        ),
      );
    }

    final allowedMethods = policy.allowedMethods
        .map((allowed) => allowed.toUpperCase())
        .toSet();
    if (!allowedMethods.contains(normalizedMethod)) {
      failures.add(
        ApiFailure(
          code: ApiFailureCode.methodNotAllowed,
          message: 'HTTP method "' + normalizedMethod + '" is not allowed.',
        ),
      );
    }

    if (bodyBytes < 0 || bodyBytes > policy.maxBodyBytes) {
      failures.add(
        const ApiFailure(
          code: ApiFailureCode.payloadTooLarge,
          message: 'Request body exceeds the configured byte limit.',
        ),
      );
    }

    return ApiValidationResult(
      List<ApiFailure>.unmodifiable(failures),
    );
  }

  int _depth(Object? value) {
    if (value is Map) {
      if (value.isEmpty) return 1;
      var deepest = 0;
      for (final child in value.values) {
        final childDepth = _depth(child);
        if (childDepth > deepest) deepest = childDepth;
      }
      return deepest + 1;
    }
    if (value is List) {
      if (value.isEmpty) return 1;
      var deepest = 0;
      for (final child in value) {
        final childDepth = _depth(child);
        if (childDepth > deepest) deepest = childDepth;
      }
      return deepest + 1;
    }
    return 0;
  }
}
