import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/ui_v35/pages/micro_breaks_screen.dart';

void main() {
  group('MicroBreaksScreen', () {
    testWidgets('renders initial state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MicroBreaksScreen()));

      expect(find.text('Micro-Break'), findsOneWidget);
      expect(find.text('Relax your eyes. Follow the rhythm.'), findsOneWidget);
      expect(find.text('Breathe In...'), findsOneWidget);
      expect(find.text('Cycle 1 of 3'), findsOneWidget);
      expect(find.text('Skip Break'), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('transitions through breathing phases automatically', (
      WidgetTester tester,
    ) async {
      // Need fake_async when dealing with periodic Timer / Future.delayed in UI
      // but flutter_test's pump mechanisms usually handle this.
      // Let's use fake_async for better timer control.

      await tester.pumpWidget(const MaterialApp(home: MicroBreaksScreen()));

      // Initial Phase: Inhale
      expect(find.text('Breathe In...'), findsOneWidget);

      // Inhale is an AnimationController forward.
      // We advance time by 4 seconds (duration of inhale).
      await tester.pump(const Duration(seconds: 4));
      // After pump, AnimationController finishes, calls setState for Hold In.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // AnimatedSwitcher

      // Phase: Hold In
      expect(find.text('Hold...'), findsOneWidget);

      // Wait for hold in timer (4 seconds)
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // AnimatedSwitcher

      // Phase: Exhale
      expect(find.text('Breathe Out...'), findsOneWidget);

      // Wait for exhale animation to complete (4 seconds)
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // AnimatedSwitcher

      // Phase: Hold Out
      expect(find.text('Relax...'), findsOneWidget);

      // Wait for hold out timer (4 seconds)
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // AnimatedSwitcher

      // Back to Inhale, Cycle 2
      expect(find.text('Breathe In...'), findsOneWidget);
      expect(find.text('Cycle 2 of 3'), findsOneWidget);
    });

    testWidgets('calls onComplete when max cycles are reached', (
      WidgetTester tester,
    ) async {
      bool onCompleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MicroBreaksScreen(
            onComplete: () {
              onCompleteCalled = true;
            },
          ),
        ),
      );

      // We have 3 cycles. Each cycle is 16 seconds (4x 4s phases).
      // Since it's a mix of AnimationController and Timer, a single large jump
      // might skip the status listeners and Timer callbacks.
      // We'll simulate each phase step by step for all 3 cycles.

      for (int i = 0; i < 3; i++) {
        // Inhale (4s animation)
        await tester.pump(const Duration(seconds: 4));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Hold In (4s timer)
        await tester.pump(const Duration(seconds: 4));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Exhale (4s animation)
        await tester.pump(const Duration(seconds: 4));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Hold Out (4s timer)
        await tester.pump(const Duration(seconds: 4));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      expect(onCompleteCalled, isTrue);
    });

    testWidgets('calls onComplete when Skip Break is pressed', (
      WidgetTester tester,
    ) async {
      bool onCompleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MicroBreaksScreen(
            onComplete: () {
              onCompleteCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Skip Break'));
      await tester.pumpAndSettle();

      expect(onCompleteCalled, isTrue);
    });

    testWidgets(
      'pops the navigator if onComplete is null and Skip Break is pressed',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MicroBreaksScreen(),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        );

        // Navigate to MicroBreaksScreen
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.byType(MicroBreaksScreen), findsOneWidget);

        // Tap Skip Break
        await tester.tap(find.text('Skip Break'));
        await tester.pumpAndSettle();

        // Should be back on the original screen
        expect(find.byType(MicroBreaksScreen), findsNothing);
        expect(find.text('Go'), findsOneWidget);
      },
    );
  });
}
