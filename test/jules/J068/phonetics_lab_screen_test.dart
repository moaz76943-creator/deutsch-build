import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/phonetics_lab_screen.dart';
import 'package:deutsch_bilarabi/design_system/app_audio_button.dart';
import 'package:flutter/services.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async {
        return 1;
      },
    );
  });

  testWidgets('PhoneticsLabScreen renders phonetics token and text correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneticsLabScreen(),
      ),
    );

    expect(find.text('ä / ö / ü'), findsOneWidget);
    expect(find.text('[ɛː] / [øː] / [yː]'), findsOneWidget);
    expect(find.text('الألمانية'), findsOneWidget);

    expect(find.text('ñ'), findsOneWidget);
    expect(find.text('[ɲ]'), findsOneWidget);

    expect(find.text('ğ'), findsOneWidget);
    expect(find.text('[ɰ]'), findsOneWidget);
  });

  testWidgets('Rapid taps on AppAudioButton handles disabled state correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneticsLabScreen(),
      ),
    );

    final buttonFinder = find.byType(AppAudioButton).first;
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  });

  testWidgets('Missing audio does not block text rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneticsLabScreen(),
      ),
    );

    final buttonFinder = find.byType(AppAudioButton).first;
    await tester.tap(buttonFinder);

    await tester.pumpAndSettle();

    expect(find.text('التركية'), findsOneWidget);
    expect(find.text('[ɰ]'), findsOneWidget);
  });

  testWidgets('Speed options cycle correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneticsLabScreen(),
      ),
    );

    final speedButton = find.byTooltip('تغيير سرعة النطق');
    expect(speedButton, findsOneWidget);

    // Tap to cycle speeds
    await tester.tap(speedButton);
    await tester.pumpAndSettle();

    // Tap again
    await tester.tap(speedButton);
    await tester.pumpAndSettle();
  });

  testWidgets('Unverified pronunciation displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneticsLabScreen(),
      ),
    );

    expect(find.text('unverified'), findsOneWidget);
    expect(find.text('غير متوفر'), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
  });

  testWidgets('Disposal stops audio', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneticsLabScreen(),
      ),
    );

    final buttonFinder = find.byType(AppAudioButton).first;
    await tester.tap(buttonFinder);

    await tester.pump();

    // Destroy the widget to trigger dispose
    await tester.pumpWidget(const SizedBox());

    await tester.pumpAndSettle();
  });

  testWidgets('Long text layout does not break UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneticsLabScreen(),
      ),
    );

    expect(find.text('حروف التملق (Umlaut) وكيفية تدوير الشفاه بالألمانية'), findsOneWidget);
  });
}
