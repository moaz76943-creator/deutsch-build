import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  test('success and failure payloads use typed accessors', () {
    const good = OperationResult<int>.success(12);
    const bad = OperationResult<int>.failure(
      InvalidInputFailure('INVALID', 'bad input'),
    );
    expect(good.isSuccess, isTrue);
    expect(good.data, 12);
    expect(() => good.failure, throwsStateError);
    expect(bad.isSuccess, isFalse);
    expect(bad.failure, isA<InvalidInputFailure>());
    expect(() => bad.data, throwsStateError);
  });

  test('private low-level causes are not logged', () {
    const bad = StorageFailure('STORAGE', 'read unavailable', 'secret token');
    expect(bad.toString(), isNot(contains('secret token')));
    expect(bad.toString(), contains('STORAGE'));
    expect(bad.hasCause, isTrue);

    const noCause = StorageFailure('STORAGE', 'read unavailable');
    expect(noCause.hasCause, isFalse);
  });
}
