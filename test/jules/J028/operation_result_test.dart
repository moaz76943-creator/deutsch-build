import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  group('OperationResult', () {
    test('Success state', () {
      const result = OperationResult.success('Test Data');
      expect(result.isSuccess, isTrue);
      expect(result.data, 'Test Data');
    });

    test('Failure state mapping and cause preservation', () {
      final cause = Exception('Underlying cause');

      final unavailableResult = OperationResult<String>.unavailable('UNAVAILABLE', 'Service unavailable', cause);
      expect(unavailableResult.isSuccess, isFalse);
      expect(unavailableResult.failure, isA<UnavailableFailure>());
      expect(unavailableResult.failure.code, 'UNAVAILABLE');
      expect(unavailableResult.failure.message, 'Service unavailable');
      expect(unavailableResult.failure.cause, equals(cause));

      final invalidInputResult = OperationResult<int>.invalidInput('INVALID', 'Bad input', cause);
      expect(invalidInputResult.isSuccess, isFalse);
      expect(invalidInputResult.failure, isA<InvalidInputFailure>());
      expect(invalidInputResult.failure.code, 'INVALID');
      expect(invalidInputResult.failure.message, 'Bad input');
      expect(invalidInputResult.failure.cause, equals(cause));

      final cancelledResult = OperationResult<void>.cancelled('CANCEL', 'Operation cancelled', cause);
      expect(cancelledResult.isSuccess, isFalse);
      expect(cancelledResult.failure, isA<CancelledFailure>());
      expect(cancelledResult.failure.code, 'CANCEL');
      expect(cancelledResult.failure.message, 'Operation cancelled');
      expect(cancelledResult.failure.cause, equals(cause));

      final incompatibleResult = OperationResult<double>.incompatibleVersion('VER_ERR', 'Bad version', cause);
      expect(incompatibleResult.isSuccess, isFalse);
      expect(incompatibleResult.failure, isA<IncompatibleVersionFailure>());
      expect(incompatibleResult.failure.code, 'VER_ERR');
      expect(incompatibleResult.failure.message, 'Bad version');
      expect(incompatibleResult.failure.cause, equals(cause));

      // StorageFailure and ContentFailure shouldn't break with the new base parameter
      const storageFailure = StorageFailure('STORAGE_ERR', 'Disk full');
      final storageResult = OperationResult<void>.failure(storageFailure);
      expect(storageResult.failure, isA<StorageFailure>());
      expect(storageResult.failure.cause, isNull);
    });
  });
}
