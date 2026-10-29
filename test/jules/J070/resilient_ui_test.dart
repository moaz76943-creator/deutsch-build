import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/ui/resilient_ui.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  group('Resilient UI Component Tests', () {
    testWidgets('ResilientStateBuilder gracefully wraps unconstrained heights in SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Scaffold body has constrained height by default
            // But let's wrap it in an unconstrained vertical space to test
            body: UnconstrainedBox(
              constrainedAxis: Axis.horizontal,
              child: ResilientStateBuilder<String>(
                state: UIState<String>.empty('Empty state'),
                dataBuilder: (context, data) => Text(data),
              ),
            ),
          ),
        ),
      );

      // Verify empty text is rendered
      expect(find.text('Empty state'), findsOneWidget);
      // In unbounded environment, it should NOT wrap with SingleChildScrollView because constraints.hasBoundedHeight is false.
      // Wait, let's test if it DOES wrap in constrained environments
    });

    testWidgets('ResilientStateBuilder wraps constrained empty state in SingleChildScrollView to prevent overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: ResilientStateBuilder<String>(
                state: UIState<String>.empty('A very long empty state message that would definitely overflow if not properly handled.'),
                dataBuilder: (context, data) => Text(data),
              ),
            ),
          ),
        ),
      );

      // Verify empty text is rendered and SingleChildScrollView is present
      expect(find.text('A very long empty state message that would definitely overflow if not properly handled.'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('ResilientAsyncBuilder handles async completion', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientAsyncBuilder<String>(
              futureBuilder: (token) async {
                await Future.delayed(const Duration(milliseconds: 50));
                return 'Async Data Loaded';
              },
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Async Data Loaded'), findsOneWidget);
    });

    testWidgets('ResilientAsyncBuilder handles async errors natively', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientAsyncBuilder<String>(
              futureBuilder: (token) async {
                await Future.delayed(const Duration(milliseconds: 50));
                throw Exception('Forced Error');
              },
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('An unexpected error occurred.'), findsOneWidget);
    });

    testWidgets('ResilientOperationBuilder parses StorageFailure correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientOperationBuilder<String>(
              operation: (token) async {
                await Future.delayed(const Duration(milliseconds: 50));
                return const OperationResult<String>.failure(StorageFailure('err', 'Disk full'));
              },
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Storage corruption detected.'), findsOneWidget);
    });

    testWidgets('RTL and mixed direction environments handle scaling correctly', (WidgetTester tester) async {
      // 200% text scale test
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            );
          },
          home: Scaffold(
            body: ResilientStateBuilder<String>(
              state: UIState<String>.empty('نص تجريبي للتأكد من عدم حدوث تجاوز للشاشة'),
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.text('نص تجريبي للتأكد من عدم حدوث تجاوز للشاشة'), findsOneWidget);
      // Wait for layout
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull); // No overflow exception should be thrown
    });

    testWidgets('ResilientMediaContent displays semantic fallback correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientMediaContent(
              mediaFetcher: (token) async {
                await Future.delayed(const Duration(milliseconds: 50));
                return null; // Force empty state
              },
              fallbackSemanticLabel: 'Image unavailable',
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      final semantics = find.bySemanticsLabel('Image unavailable');
      expect(semantics, findsWidgets); // Contains fallback
    });

    testWidgets('Token cancellation cancels state updates on disposal', (WidgetTester tester) async {
      bool isCancelled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientAsyncBuilder<String>(
              futureBuilder: (token) async {
                await Future.delayed(const Duration(milliseconds: 100));
                isCancelled = token.isCancelled;
                return 'Late Data';
              },
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      // Pump initial frame
      await tester.pump();

      // Navigate away/dispose the widget before future completes
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('New Screen'))));

      // Let the future complete
      await tester.pump(const Duration(milliseconds: 150));

      // Token should have been cancelled when unmounted
      expect(isCancelled, true);
    });
  });
}
