import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  group('OperationResult', () {
    test('success outcome instantiation and properties', () {
      final result = OperationResult<String>.success('Hello');

      expect(result.isSuccess, isTrue);
      expect(result.data, 'Hello');
      expect(result is SuccessOutcome<String>, isTrue);

      expect(() => result.failure, throwsA(isA<TypeError>()));
    });

    test('failure outcome instantiation and typed resolution', () {
      final genericFailure = ContentFailure('E1', 'Failed', cause: 'Network timeout');
      final result1 = OperationResult<String>.failure(genericFailure);

      expect(result1.isSuccess, isFalse);
      expect(result1.failure.code, 'E1');
      expect(result1.failure.cause, 'Network timeout');
      expect(result1 is GenericFailureOutcome<String>, isTrue);
      expect(() => result1.data, throwsA(isA<TypeError>()));

      final unavailableResult = OperationResult<String>.failure(
          const UnavailableFailure('E2', 'Unavailable', cause: 'Server down'));
      expect(unavailableResult is UnavailableOutcome<String>, isTrue);
      expect(unavailableResult.failure.cause, 'Server down');

      final invalidInputResult = OperationResult<String>.failure(
          const InvalidInputFailure('E3', 'Invalid'));
      expect(invalidInputResult is InvalidInputOutcome<String>, isTrue);

      final cancelledResult = OperationResult<String>.failure(
          const CancelledFailure('E4', 'Cancelled'));
      expect(cancelledResult is CancelledOutcome<String>, isTrue);

      final incompatibleResult = OperationResult<String>.failure(
          const IncompatibleVersionFailure('E5', 'Incompatible'));
      expect(incompatibleResult is IncompatibleVersionOutcome<String>, isTrue);
    });

    test('success with null data throws TypeError when accessing .data getter', () {
      final result = OperationResult<String?>.success(null);
      expect(result.isSuccess, isTrue);

      // Since `data` is implemented as `T get data => _data!;`, accessing it when
      // _data is null throws a TypeError (Null check operator used on a null value).
      expect(() => result.data, throwsA(isA<TypeError>()));
    });
  });
}
