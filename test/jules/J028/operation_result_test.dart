import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  group('OperationResult', () {
    test('Success returns data and throws on failure access', () {
      final result = OperationResult<String>.success('Hello');

      expect(result.isSuccess, isTrue);
      expect(result.data, 'Hello');
      expect(() => result.failure, throwsStateError);
    });

    test('Failure returns failure and throws on data access', () {
      final failure = InvalidInputFailure('400', 'Bad Request');
      final result = OperationResult<String>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.failure, failure);
      expect(() => result.data, throwsStateError);
    });

    test('Typed failures work correctly', () {
      expect(UnavailableFailure('1', 'a').code, '1');
      expect(InvalidInputFailure('2', 'b').message, 'b');
      expect(CancelledFailure('3', 'c').cause, null);
      expect(IncompatibleVersionFailure('4', 'd', Exception('cause')).cause, isA<Exception>());
      expect(StorageFailure('5', 'e').code, '5');
      expect(ContentFailure('6', 'f').message, 'f');
    });

    test('toString hides sensitive cause data', () {
      final sensitiveData = {'user': 'johndoe', 'score': 100};
      final failure = InvalidInputFailure('ERR_123', 'Invalid input provided', sensitiveData);

      final stringRepr = failure.toString();
      expect(stringRepr, contains('ERR_123'));
      expect(stringRepr, contains('Invalid input provided'));
      expect(stringRepr, isNot(contains('johndoe')));
      expect(stringRepr, isNot(contains('sensitiveData')));
    });
  });
}
