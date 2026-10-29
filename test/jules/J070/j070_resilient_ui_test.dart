import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/ui/components/resilient_network_image.dart';
import 'package:deutsch_bilarabi/core/ui/components/resilient_async_builder.dart';
import 'package:deutsch_bilarabi/core/ui/states/content_loading_state.dart';
import 'package:deutsch_bilarabi/core/ui/states/content_error_state.dart';
import 'package:deutsch_bilarabi/core/ui/states/content_empty_state.dart';

void main() {
  group('Resilient UI Components Tests', () {
    testWidgets('ContentLoadingState renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentLoadingState(message: 'Loading data...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('ContentEmptyState renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentEmptyState(message: 'No data found'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No data found'), findsOneWidget);
    });

    testWidgets('ContentErrorState renders and retries', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentErrorState(
              error: Exception('Test Error'),
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'), findsOneWidget);

      final retryButton = find.byType(ElevatedButton);
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      expect(retryPressed, isTrue);
    });

    testWidgets('ResilientAsyncBuilder handles success state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientAsyncBuilder<String>(
              futureBuilder: (token) => Future.value('Success Data'),
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Data is loaded
      expect(find.text('Success Data'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('ResilientAsyncBuilder handles error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResilientAsyncBuilder<String>(
              futureBuilder: (token) => Future.error(Exception('Failed to load')),
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('ResilientAsyncBuilder handles future updates (didUpdateWidget)', (WidgetTester tester) async {
      Widget buildTestWidget(Future<String> Function() factory) {
        return MaterialApp(
          home: Scaffold(
            body: ResilientAsyncBuilder<String>(
              futureBuilder: (token) => factory(),
              dataBuilder: (context, data) => Text(data),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildTestWidget(() => Future.value('First Data')));
      await tester.pumpAndSettle();
      expect(find.text('First Data'), findsOneWidget);

      await tester.pumpWidget(buildTestWidget(() => Future.value('Second Data')));
      await tester.pumpAndSettle();
      expect(find.text('Second Data'), findsOneWidget);
    });

    testWidgets('Resilient UI layout and RTL text scaling (2.0)', (WidgetTester tester) async {
      // Simulate narrow screen
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;

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
          home: const Scaffold(
            body: ContentErrorState(error: 'Some error'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Reset window size
      addTearDown(() {
         tester.view.resetPhysicalSize();
         tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('ResilientNetworkImage handles semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResilientNetworkImage(
              imageUrl: 'http://example.com/image.png',
              semanticLabel: 'Example Image',
            ),
          ),
        ),
      );

      final semanticsFinder = find.bySemanticsLabel('Example Image');
      expect(semanticsFinder, findsOneWidget);
    });
  });
}
