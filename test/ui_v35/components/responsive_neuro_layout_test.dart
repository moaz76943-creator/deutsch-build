import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/ui_v35/components/responsive_neuro_layout.dart';

void main() {
  group('ResponsiveNeuroLayout', () {
    testWidgets('renders SafeArea and Center appropriately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveNeuroLayout(
              scrollable: false,
              child: Text('Neuro Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.text('Neuro Test'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('respects scrollable constraint and adds thumb-zone padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveNeuroLayout(
              scrollable: true,
              child: Text('Scrollable Neuro Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Look for the specific padding we injected
      final paddingFinder = find
          .ancestor(
            of: find.text('Scrollable Neuro Test'),
            matching: find.byType(Padding),
          )
          .first;

      final Padding paddingWidget = tester.widget(paddingFinder);
      expect(paddingWidget.padding, const EdgeInsets.only(bottom: 80.0));
    });

    testWidgets('respects max width constraint', (WidgetTester tester) async {
      // Create a wide screen
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveNeuroLayout(
              maxWidth: 500.0,
              scrollable: false,
              child: Container(
                key: const Key('inner_child'),
                width: double.infinity,
                height: 100,
              ),
            ),
          ),
        ),
      );

      // The child tries to be infinite width, but should be constrained to 500
      final Size childSize = tester.getSize(
        find.byKey(const Key('inner_child')),
      );
      expect(childSize.width, 500.0);

      // Reset
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
