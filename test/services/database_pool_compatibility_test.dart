import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

void main() {
  test('content pool trimming API remains available to memory-pressure callers',
      () async {
    final closed = await DatabaseService.instance
        .trimUnleasedContentConnections();
    expect(closed, greaterThanOrEqualTo(0));
  });
}
