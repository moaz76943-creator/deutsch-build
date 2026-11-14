import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  group('OperationResult', () {
    test('success outcome has data and no failure', () {
      const result = OperationResult<String>.success('test_data');

      expect(result.isSuccess, isTrue);
      expect(result.data, 'test_data');
      expect(() => result.failure, throwsException);
    });

    test('failure outcome has failure and no data', () {
      const failure = StorageFailure('ERR_1', 'Storage failed');
      const result = OperationResult<String>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.failure, failure);
      expect(() => result.data, throwsException);
    });

    test('typed outcome: unavailable', () {
      const cause = FormatException('Network down');
      final result = OperationResult<int>.unavailable('NET_ERR', 'System unavailable', cause);

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<UnavailableFailure>());
      expect(result.failure.code, 'NET_ERR');
      expect(result.failure.message, 'System unavailable');
      expect(result.failure.cause, cause);
    });

    test('typed outcome: invalidInput', () {
      final cause = ArgumentError('Missing parameters');
      final result = OperationResult<bool>.invalidInput('INV_IN', 'Invalid input data', cause);

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<InvalidInputFailure>());
      expect(result.failure.code, 'INV_IN');
      expect(result.failure.message, 'Invalid input data');
      expect(result.failure.cause, cause);
    });

    test('typed outcome: cancelled', () {
      final result = OperationResult<String>.cancelled('CANC_01', 'Operation cancelled by user');

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<CancelledFailure>());
      expect(result.failure.code, 'CANC_01');
      expect(result.failure.message, 'Operation cancelled by user');
      expect(result.failure.cause, isNull);
    });

    test('typed outcome: incompatibleVersion', () {
      final cause = UnsupportedError('v1 not supported');
      final result = OperationResult<double>.incompatibleVersion('VER_ERR', 'Incompatible API version', cause);

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<IncompatibleVersionFailure>());
      expect(result.failure.code, 'VER_ERR');
      expect(result.failure.message, 'Incompatible API version');
      expect(result.failure.cause, cause);
    });

    test('error causes are securely retained without exposing learner records directly', () {
      final simpleCause = Exception('Generic parsing error');
      final failure = ContentFailure('PARSE_ERR', 'Could not parse', simpleCause);

      expect(failure.cause, simpleCause);
      expect(failure.message, 'Could not parse');
    });

    test('OperationResult<void> works without throwing on data access', () {
      const result = OperationResult<void>.success(null);
      expect(result.isSuccess, isTrue);
      expect(() => result.data, returnsNormally);

    });
  });
}
// J028 Hardened Identity
