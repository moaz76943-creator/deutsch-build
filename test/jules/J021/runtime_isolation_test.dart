import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/resilience/bounded_retry_policy.dart';
import 'package:deutsch_bilarabi/core/resilience/failure_reasons.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';

void main() {
  group('J021 - Runtime Feature Isolation & Failure Recovery', () {
    testWidgets('Optional feature failure correctly stops at max retries',
        (tester) async {
      var initAttempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Test Feature',
              retryPolicy: BoundedRetryPolicy(
                maxAttempts: 3,
                initialDelay: Duration.zero,
              ),
              initializationAction: () async {
                initAttempts++;
                throw const MissingOfflineVoiceFailure();
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(initAttempts, 3);
      expect(find.text('يعمل Test Feature بوضع محدود'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets(
        'Session key changes cancel ongoing operations and reject stale success',
        (tester) async {
      final gate = Completer<void>();
      var finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Test Feature',
              sessionId: 'session-1',
              retryPolicy: BoundedRetryPolicy(
                maxAttempts: 1,
                initialDelay: Duration.zero,
              ),
              initializationAction: () async {
                await gate.future;
                finished = true;
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Test Feature',
              sessionId: 'session-2',
              child: const Text('Success'),
            ),
          ),
        ),
      );

      gate.complete();
      await tester.pump();
      expect(finished, isTrue);
      expect(find.text('يعمل Test Feature بوضع محدود'), findsNothing);
      expect(find.text('Success'), findsNothing);
    });

    testWidgets(
        'Missing optional feature proper triggers fallback without crashing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Dictionary',
              retryPolicy: BoundedRetryPolicy(
                maxAttempts: 1,
                initialDelay: Duration.zero,
              ),
              initializationAction: () async {
                throw const MissingDictionaryFailure();
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('يعمل Dictionary بوضع محدود'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Critical errors fail closed instead of showing the child',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Storage',
              initializationAction: () async {
                throw const InvalidVaultFailure();
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('تعذر تشغيل Storage'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
