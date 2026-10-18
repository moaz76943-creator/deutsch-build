import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/main.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';

void main() {
  testWidgets('App Launch Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const DeutschApp());
    expect(find.byType(StartupBoundary), findsOneWidget);
    // Let the boot timeout and stability window fire so no timer outlives the test.
    await tester.pump(const Duration(seconds: 25));
    await tester.pumpWidget(const SizedBox());
  });
}
