import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/resilience/failure_reasons.dart';
import 'package:deutsch_bilarabi/core/resilience/bounded_retry_policy.dart';
import 'dart:async';

void main() {
  group('J021 - Runtime Feature Isolation & Failure Recovery', () {
    testWidgets('Optional feature failure correctly stops at max retries', (tester) async {
      int initAttempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Test Feature',
              retryPolicy: BoundedRetryPolicy(maxAttempts: 2, initialDelay: Duration.zero),
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

      expect(initAttempts, 2);
      expect(find.text('حدث خطأ في Test Feature'), findsOneWidget);
    });

    testWidgets('Session key changes cancel ongoing operations and reject stale success', (tester) async {
      int initAttempts = 0;
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              key: boundaryKey,
              featureName: 'Test Feature',
              sessionId: 'session-1',
              retryPolicy: BoundedRetryPolicy(maxAttempts: 1, initialDelay: Duration.zero),
              initializationAction: () async {
                initAttempts++;
                await Future.delayed(const Duration(milliseconds: 100));
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      // It should be loading initially
      expect(find.text('جاري تحديث Test Feature تلقائياً...'), findsOneWidget);
      expect(initAttempts, 1);

      // Change session key before the previous operation finishes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              key: boundaryKey,
              featureName: 'Test Feature',
              sessionId: 'session-2',
              retryPolicy: BoundedRetryPolicy(maxAttempts: 1, initialDelay: Duration.zero),
              initializationAction: () async {
                initAttempts++;
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));

      // Should show success and initAttempts should be 2 because the first was cancelled/stale, and second completed
      expect(find.text('Success'), findsOneWidget);
      expect(initAttempts, 2);
    });

    testWidgets('Missing optional feature proper triggers fallback without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Dictionary',
              retryPolicy: BoundedRetryPolicy(maxAttempts: 1, initialDelay: Duration.zero),
              initializationAction: () async {
                throw const MissingDictionaryFailure();
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('حدث خطأ في Dictionary'), findsOneWidget);
    });

    testWidgets('Critical errors immediately rethrow and fail-closed', (tester) async {
      Object? caughtError;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Storage',
              retryPolicy: BoundedRetryPolicy(maxAttempts: 1, initialDelay: Duration.zero),
              initializationAction: () async {
                throw const InvalidVaultFailure();
              },
              onCriticalFailure: (err, stack) {
                caughtError = err;
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('تعذر تشغيل Storage'), findsOneWidget);
      expect(caughtError, isA<InvalidVaultFailure>());
    });
  });
}
