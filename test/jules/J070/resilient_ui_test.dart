import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/ui/components/resilient_content_builder.dart';
import 'package:deutsch_bilarabi/core/ui/components/resilient_media_placeholder.dart';

void main() {
  group('ResilientContentBuilder Tests', () {
    testWidgets('Displays loading, then content when ready', (WidgetTester tester) async {
      final completer = Completer<String>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResilientContentBuilder<String>(
            fetcher: () => completer.future,
            builder: (context, data) => Text('Data: $data'),
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete('ReadyContent');
      await tester.pumpAndSettle();

      expect(find.text('Data: ReadyContent'), findsOneWidget);
    });

    testWidgets('Displays empty state', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResilientContentBuilder<List<String>>(
            fetcher: () async => <String>[],
            builder: (context, data) => Text('Items: ${data.length}'),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('No content available'), findsOneWidget);
    });

    testWidgets('Displays failed state on exception', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResilientContentBuilder<String>(
            fetcher: () async {
              throw Exception('Network error');
            },
            builder: (context, data) => Text('Data: $data'),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('Operation Failed'), findsOneWidget);
    });

    testWidgets('Displays corrupted state on FormatException', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResilientContentBuilder<String>(
            fetcher: () async {
              throw const FormatException('Invalid JSON');
            },
            builder: (context, data) => Text('Data: $data'),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('Data Corrupted'), findsOneWidget);
    });

    testWidgets('Times out and shows error', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ResilientContentBuilder<String>(
              fetcher: () async => Future.delayed(const Duration(milliseconds: 200), () => 'Late'),
              timeout: const Duration(milliseconds: 50),
              builder: (context, data) => Text('Data: $data'),
            ),
          ),
        ));

        await Future.delayed(const Duration(milliseconds: 60));
        await tester.pumpAndSettle();
        expect(find.text('Operation Failed'), findsOneWidget);
      });
    });
  });

  group('ResilientMediaPlaceholder Tests', () {
    testWidgets('Renders with correct fallback and RTL', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ResilientMediaPlaceholder(
            semanticLabel: 'Semantic Arabic Text',
            fallbackText: 'مفقود',
            bcp47LanguageCode: 'ar-SA',
          ),
        ),
      ));

      expect(find.text('مفقود'), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);

      final directionality = tester.widget<Directionality>(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Directionality),
        ).first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('Handles large text scaling without overflow bounds', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
            child: SizedBox(
              height: 300, // Fixed tight constraint
              width: 300,
              child: const ResilientMediaPlaceholder(
                semanticLabel: 'Test',
                fallbackText: 'This is a very long text that would normally overflow if not handled correctly with a scroll view.',
              ),
            ),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('This is a very long text that would normally overflow if not handled correctly with a scroll view.'), findsOneWidget);
    });
  });
}
