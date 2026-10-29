import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/ui/components/resilient_async_builder.dart';
import 'package:deutsch_bilarabi/core/ui/components/optional_media_widget.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';

void main() {
  group('Resilient UI Components', () {
    testWidgets('ResilientAsyncBuilder handles success state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientOperationBuilder<String>(
              // featureName: 'TestFeature',
              operation: (token) async => OperationResult.success('Success Data'),
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Success Data'), findsOneWidget);
    });

    testWidgets('ResilientAsyncBuilder handles empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientOperationBuilder<String>(
              // featureName: 'TestFeature',
              operation: (token) async => OperationResult.failure(const ContentFailure('empty', 'No Data Here')),
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('No offline content available.'), findsOneWidget);
    });

    testWidgets('ResilientAsyncBuilder handles failed state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientOperationBuilder<String>(
              // featureName: 'TestFeature',
              operation: (token) async => OperationResult.failure(const UnavailableFailure('error', 'Something went wrong')),
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('ResilientAsyncBuilder handles degraded state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientOperationBuilder<String>(
              // featureName: 'TestFeature',
              operation: (token) async => const OperationResult.success('Stale Data'), // degraded was removed in new API
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Degraded removed from base API
      // expect(find.text('Warning: Offline mode'), findsOneWidget);
      expect(find.text('Stale Data'), findsOneWidget);
    });

    testWidgets('OptionalMediaWidget falls back correctly when media missing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionalMediaWidget(
              fetcher: () async => null,
              semanticLabel: 'A beautiful tree',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('A beautiful tree'), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('ResilientAsyncBuilder scales text appropriately without overflowing in unbounded parents', (WidgetTester tester) async {
      // Narrow screen
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
              child: child!,
            );
          },
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResilientOperationBuilder<String>(
                // featureName: 'ScaleFeature',
                operation: (token) async => OperationResult.failure(const ContentFailure('error', 'A very long error message that might cause overflow if not wrapped correctly without Flexible/Expanded')),
                dataBuilder: (context, data) => Text(data),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Test will fail if there are layout overflows that go unhandled
      expect(tester.takeException(), isNull);

      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('ResilientAsyncBuilder supports RTL fallback text direction via AppDirectionalText', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientOperationBuilder<String>(
              // featureName: 'TestFeature',
              operation: (token) async => OperationResult.success('Data'),
              dataBuilder: (context, data) => const AppDirectionalText('مرحبا بالعالم'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('مرحبا بالعالم'), findsOneWidget);
      // Wait for the tree to build Directionality from AppDirectionalText
      final textWidgets = tester.widgetList<Directionality>(find.byType(Directionality));
      final hasRtl = textWidgets.any((w) => w.textDirection == TextDirection.rtl);
      expect(hasRtl, true);
    });
  });
}
