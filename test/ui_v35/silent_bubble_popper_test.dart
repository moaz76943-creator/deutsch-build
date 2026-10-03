import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/ui_v35/pages/silent_bubble_popper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Widget createTestWidget({VoidCallback? onComplete}) {
    return MaterialApp(
      home: SilentBubblePopper(
        fetchVocabulary: () async => <Map<String, dynamic>>[],
        onComplete: onComplete,
      ),
    );
  }

  testWidgets(
    'SilentBubblePopper renders correctly and uses fallback data if no DB entries',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump repeatedly to wait for future to resolve
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify static texts
      expect(find.text('Silent Popper'), findsOneWidget);
      expect(find.text('Match the words to pop the bubbles.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Verify fallback data is rendered.
      // Fallback data includes Apfel, Buch, Wasser, Haus and their translations.
      expect(find.text('Apfel'), findsOneWidget);
      expect(find.text('Buch'), findsOneWidget);
      expect(find.text('تفاحة'), findsOneWidget);
      expect(find.text('كتاب'), findsOneWidget);
    },
  );

  testWidgets('Matching logic works and bubbles disappear', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Bubble positions are randomized and continuously animated, so a text
    // center can be obscured by another bubble at the instant of a hit test.
    // This test verifies matching state logic deterministically by invoking
    // the actual tappable GestureDetector for each matching bubble.
    final apfelBubble = find.ancestor(
      of: find.text('Apfel'),
      matching: find.byType(GestureDetector),
    );
    final arabicBubble = find.ancestor(
      of: find.text('تفاحة'),
      matching: find.byType(GestureDetector),
    );

    expect(apfelBubble, findsOneWidget);
    expect(arabicBubble, findsOneWidget);

    tester.widget<GestureDetector>(apfelBubble).onTap!();
    await tester.pump(const Duration(milliseconds: 100));

    tester.widget<GestureDetector>(arabicBubble).onTap!();
    await tester.pump(const Duration(milliseconds: 100));

    // Bubbles should be removed
    expect(find.text('Apfel'), findsNothing);
    expect(find.text('تفاحة'), findsNothing);
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

    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(onCompleteCalled, isTrue);
  });
}
