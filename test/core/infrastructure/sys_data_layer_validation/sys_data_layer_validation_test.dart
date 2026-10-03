import 'package:deutsch_bilarabi/core/infrastructure/sys_data_layer_validation/data_models_hub.dart';
import 'package:deutsch_bilarabi/core/infrastructure/sys_data_layer_validation/safe_input_validator.dart';
import 'package:deutsch_bilarabi/core/infrastructure/sys_data_layer_validation/type_safety_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TypeSafetyValidator', () {
    const validator = TypeSafetyValidator();
    const schema = DataSchema(
      fields: <String, DataField>{
        'id': DataField(type: DataValueType.integer),
        'name': DataField(type: DataValueType.string),
        'active': DataField(type: DataValueType.boolean, required: false),
        'note': DataField(
          type: DataValueType.string,
          required: false,
          nullable: true,
        ),
      },
    );

    test('accepts a valid typed object', () {
      final result = validator.validate(
        <String, Object?>{'id': 7, 'name': 'Salim', 'active': true},
        schema,
      );

      expect(result.isValid, isTrue);
      expect(result.failures, isEmpty);
    });

    test('reports null violations and type mismatches', () {
      final result = validator.validate(
        <String, Object?>{'id': '7', 'name': null},
        schema,
      );

      expect(
        result.failures.map((failure) => failure.code),
        containsAll(<DataFailureCode>[
          DataFailureCode.typeMismatch,
          DataFailureCode.nullNotAllowed,
        ]),
      );
    });

    test('capture converts thrown errors into explicit failure results', () {
      final result = validator.capture<int>(() {
        throw StateError('boom');
      });

      expect(result.isSuccess, isFalse);
      expect(result.failure?.code, DataFailureCode.operationFailed);
      expect(result.failure?.message, contains('StateError'));
    });
  });

  group('SafeInputValidator', () {
    const validator = SafeInputValidator();

    test('decodes JSON objects and rejects non-object roots', () {
      final valid = validator.decodeJsonObject('{"id":1,"name":"ok"}');
      final invalid = validator.decodeJsonObject('[1,2,3]');

      expect(valid.isSuccess, isTrue);
      expect(valid.value?['id'], 1);
      expect(invalid.failure?.code, InputFailureCode.nonObjectJson);
    });

    test('rejects oversized and deeply nested JSON', () {
      final rawLarge =
          '{"data":"' + List<String>.filled(80, 'x').join() + '"}';
      final oversized = validator.decodeJsonObject(
        rawLarge,
        maxBytes: 20,
      );
      final deep = validator.decodeJsonObject(
        '{"a":{"b":{"c":{"d":1}}}}',
        maxDepth: 2,
      );

      expect(oversized.failure?.code, InputFailureCode.payloadTooLarge);
      expect(deep.failure?.code, InputFailureCode.maxDepthExceeded);
    });

    test('API policy requires HTTPS, allowed host and allowed method', () {
      const policy = ApiRequestPolicy(
        allowedHosts: <String>{'api.example.com'},
        allowedMethods: <String>{'GET', 'POST'},
      );

      expect(
        validator.validateApiRequest(
          Uri.parse('https://api.example.com/v1/items'),
          method: 'GET',
          policy: policy,
        ).isValid,
        isTrue,
      );
      expect(
        validator.validateApiRequest(
          Uri.parse('http://api.example.com/v1/items'),
          method: 'GET',
          policy: policy,
        ).failures.single.code,
        ApiFailureCode.insecureScheme,
      );
      expect(
        validator.validateApiRequest(
          Uri.parse('https://evil.example/v1/items'),
          method: 'DELETE',
          policy: policy,
        ).failures.map((failure) => failure.code),
        containsAll(<ApiFailureCode>[
          ApiFailureCode.hostNotAllowed,
          ApiFailureCode.methodNotAllowed,
        ]),
      );
    });
  });

  test('DataModelsHub validates decoded payload against schema', () {
    const hub = DataModelsHub();
    const schema = DataSchema(
      fields: <String, DataField>{
        'id': DataField(type: DataValueType.integer),
        'title': DataField(type: DataValueType.string),
      },
    );

    final good = hub.validateJson('{"id":1,"title":"Hallo"}', schema);
    final bad = hub.validateJson('{"id":"1"}', schema);

    expect(good.isValid, isTrue);
    expect(bad.isValid, isFalse);
    expect(
      bad.typeFailures.map((failure) => failure.code),
      containsAll(<DataFailureCode>[
        DataFailureCode.typeMismatch,
        DataFailureCode.missingRequiredField,
      ]),
    );
  });
}
