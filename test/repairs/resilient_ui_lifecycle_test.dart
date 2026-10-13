import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/ui/resilient_ui.dart';

void main() {
  testWidgets('bounded RTL empty state supports large text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 88,
            width: 180,
            child: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.5),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ResilientStateBuilder<String>(
                  state: UIState<String>.empty(
                    'النص العربي طويل للغاية والواجهة يجب ألا تتجاوز الحدود',
                  ),
                  dataBuilder: (context, data) => Text(data),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('async builder ignores late completion after disposal', (tester) async {
    final completer = Completer<String?>();
    ContentCancellationToken? token;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ResilientAsyncBuilder<String>(
          futureBuilder: (issued) {
            token = issued;
            return completer.future;
          },
          dataBuilder: (context, data) => Text(data),
        ),
      ),
    ));
    expect(token?.isCancelled, false);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    expect(token?.isCancelled, true);
    completer.complete('stale');
    await tester.pump();
    expect(find.text('stale'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new request invalidates older in-flight result', (tester) async {
    final first = Completer<String?>();
    final second = Completer<String?>();

    Widget screen(int request) => MaterialApp(
      home: Scaffold(
        body: ResilientAsyncBuilder<String>(
          requestKey: request,
          futureBuilder: (_) => request == 1 ? first.future : second.future,
          dataBuilder: (context, data) => Text(data),
        ),
      ),
    );

    await tester.pumpWidget(screen(1));
    await tester.pumpWidget(screen(2));
    first.complete('stale');
    await tester.pump();
    expect(find.text('stale'), findsNothing);
    second.complete('fresh');
    await tester.pump();
    expect(find.text('fresh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sync throw becomes recoverable error UI', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ResilientAsyncBuilder<String>(
          futureBuilder: (_) => throw StateError('unexpected'),
          dataBuilder: (context, data) => Text(data),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Unable to load content.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('operation failure does not masquerade as successful data', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ResilientOperationBuilder<String>(
          operation: (_) async => const OperationResult<String>.failure(
            StorageFailure('disk_error', 'Storage is unavailable'),
          ),
          dataBuilder: (context, data) => Text(data),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Local content cannot be read.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('malformed successful operation cannot crash the widget tree',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ResilientOperationBuilder<String?>(
          operation: (_) async => const OperationResult<String?>.success(null),
          dataBuilder: (context, data) => Text(data ?? ''),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Unable to load content.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing media exposes semantic fallback', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ResilientMediaContent(
          mediaFetcher: (_) async => null,
          fallbackSemanticLabel: 'Image unavailable',
        ),
      ),
    ));
    await tester.pump();
    expect(find.bySemanticsLabel('Image unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
