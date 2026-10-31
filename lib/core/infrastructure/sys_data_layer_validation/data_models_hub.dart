import 'safe_input_validator.dart';
import 'type_safety_validator.dart';

final class DataHubValidationReport {
  const DataHubValidationReport({
    required this.inputFailure,
    required this.typeFailures,
  });

  final InputFailure? inputFailure;
  final List<DataFailure> typeFailures;

  bool get isValid => inputFailure == null && typeFailures.isEmpty;
}

final class DataModelsHub {
  const DataModelsHub({
    this.inputValidator = const SafeInputValidator(),
    this.typeValidator = const TypeSafetyValidator(),
  });

  final SafeInputValidator inputValidator;
  final TypeSafetyValidator typeValidator;

  DataHubValidationReport validateJson(
    String raw,
    DataSchema schema, {
    int maxBytes = 64 * 1024,
    int maxDepth = 16,
  }) {
    final decoded = inputValidator.decodeJsonObject(
      raw,
      maxBytes: maxBytes,
      maxDepth: maxDepth,
    );

    if (!decoded.isSuccess) {
      return DataHubValidationReport(
        inputFailure: decoded.failure,
        typeFailures: const <DataFailure>[],
      );
    }

    final typeResult = typeValidator.validate(decoded.value!, schema);
    return DataHubValidationReport(
      inputFailure: null,
      typeFailures: typeResult.failures,
    );
  }

  ApiValidationResult validateApiRequest(
    Uri uri, {
    required String method,
    required ApiRequestPolicy policy,
    int bodyBytes = 0,
  }) {
    return inputValidator.validateApiRequest(
      uri,
      method: method,
      policy: policy,
      bodyBytes: bodyBytes,
    );
  }
}
