import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/ui_v35/pages/silent_bubble_popper.dart';
import 'package:deutsch_bilarabi/services/user_vocabulary_service.dart';
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

  testWidgets('SilentBubblePopper renders correctly and uses fallback data if no DB entries', (WidgetTester tester) async {
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
  });

  testWidgets('Matching logic works and bubbles disappear', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Tap first word
    await tester.tap(find.text('Apfel'));
    await tester.pump(const Duration(milliseconds: 100)); // trigger animation frame

    // Tap matching word
    await tester.tap(find.text('تفاحة'));
    await tester.pump(const Duration(milliseconds: 100));

    // Bubbles should be removed
    expect(find.text('Apfel'), findsNothing);
    expect(find.text('تفاحة'), findsNothing);
  });

  testWidgets('Skip button calls onComplete', (WidgetTester tester) async {
    bool onCompleteCalled = false;
    await tester.pumpWidget(createTestWidget(
      onComplete: () {
        onCompleteCalled = true;
      },
    ));

    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(onCompleteCalled, isTrue);
  });
}
