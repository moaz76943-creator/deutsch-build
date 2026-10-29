import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/ui/accessible_adaptive_widgets.dart';

void main() {
  group('Accessibility & Font Scaling Tests', () {
    testWidgets('Enforces minimum 48x48 touch target constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTouchTarget(
              onTap: () {},
              semanticLabel: 'Play Pronunciation',
              child: const Icon(Icons.volume_up, size: 20),
            ),
          ),
        ),
      );

      final renderBox = tester.renderObject(find.byType(AccessibleTouchTarget)) as RenderBox;
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));

      // Verify Semantics label
      expect(
        tester.getSemantics(find.byType(AccessibleTouchTarget)).label,
        equals('Play Pronunciation'),
      );
    });

    testWidgets('AccessibleClampedText clamps extreme font scale factors safely', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: const Scaffold(
              body: AccessibleClampedText(
                'Lernfortschritt',
                maxScale: 1.5,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AccessibleClampedText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
