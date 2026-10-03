enum DataValueType { string, integer, number, boolean, object, list }

enum DataFailureCode {
  missingRequiredField,
  nullNotAllowed,
  typeMismatch,
  unknownField,
  operationFailed,
}

final class DataField {
  const DataField({
    required this.type,
    this.required = true,
    this.nullable = false,
  });

  final DataValueType type;
  final bool required;
  final bool nullable;
}

final class DataSchema {
  const DataSchema({
    required this.fields,
    this.allowUnknownFields = false,
  });

  final Map<String, DataField> fields;
  final bool allowUnknownFields;
}

final class DataFailure {
  const DataFailure({
    required this.code,
    required this.message,
    this.field,
  });

  final DataFailureCode code;
  final String message;
  final String? field;
}

final class DataValidationResult {
  const DataValidationResult(this.failures);

  final List<DataFailure> failures;

  bool get isValid => failures.isEmpty;
}

final class DataOperationResult<T> {
  const DataOperationResult._({
    this.value,
    this.failure,
  });

  const DataOperationResult.success(T value) : this._(value: value);

  const DataOperationResult.failure(DataFailure failure)
      : this._(failure: failure);

  final T? value;
  final DataFailure? failure;

  bool get isSuccess => failure == null;
}

final class TypeSafetyValidator {
  const TypeSafetyValidator();

  DataValidationResult validate(
    Map<String, Object?> payload,
    DataSchema schema,
  ) {
    final failures = <DataFailure>[];

    for (final entry in schema.fields.entries) {
      final fieldName = entry.key;
      final field = entry.value;
      final hasField = payload.containsKey(fieldName);

      if (!hasField) {
        if (field.required) {
          failures.add(
            DataFailure(
              code: DataFailureCode.missingRequiredField,
              field: fieldName,
              message: 'Required field "' + fieldName + '" is missing.',
            ),
          );
        }
        continue;
      }

      final value = payload[fieldName];
      if (value == null) {
        if (!field.nullable) {
          failures.add(
            DataFailure(
              code: DataFailureCode.nullNotAllowed,
              field: fieldName,
              message: 'Field "' + fieldName + '" does not allow null.',
            ),
          );
        }
        continue;
      }

      if (!_matchesType(value, field.type)) {
        failures.add(
          DataFailure(
            code: DataFailureCode.typeMismatch,
            field: fieldName,
            message: 'Field "' +
                fieldName +
                '" expected ' +
                field.type.name +
                ' but received ' +
                value.runtimeType.toString() +
                '.',
          ),
        );
      }
    }

    if (!schema.allowUnknownFields) {
      for (final key in payload.keys) {
        if (!schema.fields.containsKey(key)) {
          failures.add(
            DataFailure(
              code: DataFailureCode.unknownField,
              field: key,
              message: 'Unknown field "' + key + '" is not allowed.',
            ),
          );
        }
      }
    }

    return DataValidationResult(
      List<DataFailure>.unmodifiable(failures),
    );
  }

  DataOperationResult<T> capture<T>(T Function() operation) {
    try {
      return DataOperationResult<T>.success(operation());
    } on Object catch (error) {
      return DataOperationResult<T>.failure(
        DataFailure(
          code: DataFailureCode.operationFailed,
          message: error.toString(),
        ),
      );
    }
  }

  bool _matchesType(Object value, DataValueType type) {
    return switch (type) {
      DataValueType.string => value is String,
      DataValueType.integer => value is int,
      DataValueType.number => value is num,
      DataValueType.boolean => value is bool,
      DataValueType.object => value is Map,
      DataValueType.list => value is List,
    };
  }
}
