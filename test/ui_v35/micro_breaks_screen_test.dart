import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/ui_v35/pages/micro_breaks_screen.dart';

void main() {
  Widget createTestWidget({VoidCallback? onComplete}) {
    return MaterialApp(home: MicroBreaksScreen(onComplete: onComplete));
  }

  testWidgets('MicroBreaksScreen renders correctly and shows initial texts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    // Verify static texts
    expect(find.text('Micro-Break'), findsOneWidget);
    expect(find.text('Relax your eyes. Follow the rhythm.'), findsOneWidget);
    expect(find.text('Cycle 1 of 3'), findsOneWidget);
    expect(find.text('Skip Break'), findsOneWidget);

    // Verify initial phase text (inhale)
    expect(find.text('Breathe In...'), findsOneWidget);

    // Clean up animation timers
    await tester.pumpAndSettle();
  });

  testWidgets('Skip button calls onComplete', (WidgetTester tester) async {
    bool onCompleteCalled = false;
    await tester.pumpWidget(
      createTestWidget(
        onComplete: () {
          onCompleteCalled = true;
        },
      ),
    );

    await tester.tap(find.text('Skip Break'));
    await tester.pumpAndSettle();

    expect(onCompleteCalled, isTrue);
  });
}
