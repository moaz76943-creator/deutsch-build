import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/resilience/bounded_retry_policy.dart';

void main() {
  group('FeatureBoundary Resilience Tests (J021)', () {
    testWidgets('Renders child on success', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Test Feature',
              child: const Text('Success Data'),
              initializationAction: () async {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Success Data'), findsOneWidget);
    });

    testWidgets('Renders degraded view on ContentFailure (missing dictionary)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Dictionary',
              initializationAction: () async {
                throw const ContentFailure(
                    'MISSING_DICT', 'Missing optional dictionary');
              },
              retryPolicy: BoundedRetryPolicy(
                  maxAttempts: 1, initialDelay: Duration.zero),
              child: const Text('Success Data'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('يعمل Dictionary بوضع محدود'), findsOneWidget);
      expect(find.text('Success Data'),
          findsOneWidget); // Child still shown in degraded
    });

    testWidgets('Renders fallback view on StorageFailure (critical blocked)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Vault',
              child: const Text('Success Data'),
              initializationAction: () async {
                throw const StorageFailure(
                    'INVALID_VAULT', 'Storage integrity invalid');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('تعذر تشغيل Vault'), findsOneWidget);
      expect(find.text('Success Data'), findsNothing);
    });

    testWidgets(
        'Bounded retry policy correctly retries and fails on max attempts',
        (tester) async {
      int attempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Network',
              initializationAction: () async {
                attempts++;
                throw Exception('Network timeout');
              },
              retryPolicy: BoundedRetryPolicy(
                  maxAttempts: 3, initialDelay: Duration.zero),
              child: const Text('Success Data'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(attempts, 3);
      expect(find.text('يعمل Network بوضع محدود'), findsOneWidget);
    });

    testWidgets('Rejects stale callback if session ID changes', (tester) async {
      bool operationFinished = false;
      final GlobalKey boundaryKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              key: boundaryKey,
              featureName: 'Session',
              sessionId: 'session_1',
              initializationAction: () async {
                await Future.delayed(const Duration(milliseconds: 100));
                operationFinished = true;
                throw const ContentFailure('err', 'err');
              },
              retryPolicy: BoundedRetryPolicy(
                  maxAttempts: 1, initialDelay: Duration.zero),
              child: const Text('Success Data'),
            ),
          ),
        ),
      );

      // Update widget with new session before async completes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              key: boundaryKey,
              featureName: 'Session',
              sessionId: 'session_2',
              retryPolicy: BoundedRetryPolicy(
                  maxAttempts: 1, initialDelay: Duration.zero),
              child: const Text('Success Data'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(operationFinished, true);
      // State should not be updated to degraded because session changed
      expect(find.text('يعمل Session بوضع محدود'), findsNothing);
    });
  });
}
