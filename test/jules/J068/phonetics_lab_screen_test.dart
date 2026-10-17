import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/phonetics_lab_screen.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';

// Helper to provide a large height since the contents might not fit
Widget makeTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(height: 3000, child: child)),
  );
}

void main() {
  testWidgets('PhoneticsLabScreen renders correctly with basic UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneticsLabScreen()));
    await tester.pumpAndSettle();

    expect(find.text('معمل تدريب الصوتيات ومخارج الحروف'), findsOneWidget);
    expect(find.text('ä / ö / ü'), findsOneWidget);
    expect(find.text('الألمانية'), findsOneWidget);
    expect(find.textContaining('حروف الإمالة'), findsOneWidget);
    expect(find.textContaining('/ɛ/ /ø/ /y/'), findsOneWidget);
    expect(find.textContaining('ae / oe / ue'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsWidgets);
    expect(find.byIcon(Icons.slow_motion_video), findsWidgets);
  });

  testWidgets('PhoneticsLabScreen handles missing voices properly', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneticsLabScreen()));
    await tester.pumpAndSettle();

    // Entry 2 is the Turkish one which is marked with hasVerifiedAudio: false
    expect(find.text('ğ'), findsOneWidget);
    expect(find.text('التركية'), findsOneWidget);
    expect(find.text('النطق غير متوفر حالياً'), findsOneWidget);

    // Test the specific absence of buttons within the specific tile
    final turkishCard = find.ancestor(of: find.text('ğ'), matching: find.byType(Container)).first;
    expect(find.descendant(of: turkishCard, matching: find.byIcon(Icons.play_arrow)), findsNothing);
  });

  testWidgets('PhoneticsLabScreen handles mixed script (Arabic and IPA)', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneticsLabScreen()));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    // The Arabic entry
    expect(find.text('ض'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.textContaining('/dˤ/'), findsOneWidget);
  });

  testWidgets('PhoneticsLabScreen handles state change on play and dispose', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneticsLabScreen()));
    await tester.pumpAndSettle();

    // Tap the first play button
    await tester.tap(find.byIcon(Icons.play_arrow).first);
    await tester.pump();

    // Verify stop button appears (meaning state changed to playing)
    expect(find.byIcon(Icons.stop), findsOneWidget);

    // Tap stop
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    // Stop is gone
    expect(find.byIcon(Icons.stop), findsNothing);

    // Test dispose using pumpWidget to a different screen
    // We mock play
    await tester.tap(find.byIcon(Icons.play_arrow).first);
    await tester.pump();

    expect(OfflineAudioDispatcher.isPlaying, isTrue);

    // Dispose the widget by replacing it
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text("Empty"))));
    await tester.pumpAndSettle();

    expect(OfflineAudioDispatcher.isPlaying, isFalse);
  });

  testWidgets('PhoneticsLabScreen handles invalid IPA and long text gracefully', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneticsLabScreen()));
    await tester.pumpAndSettle();

    // Find the long text by scrolling to it
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(find.text("This is an extremely long description that should properly wrap within the constrained space of the phonetic entry tile. It shouldn't overflow or cause a rendering error in the list view layout."), findsOneWidget);

    // Check for invalid IPA text which we map to a special string or just don't crash
    expect(find.textContaining('IPA: Invalid IPA format detected'), findsOneWidget);
  });
}
