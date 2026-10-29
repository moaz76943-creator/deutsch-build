import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/resilience/failure_reasons.dart';
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
              maxRetries: 2,
              onInit: () async {
                initAttempts++;
                throw const MissingOfflineVoiceFailure();
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Initial fail
      expect(initAttempts, 1);
      expect(find.text('حدث خطأ في Test Feature'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      // Retry 1
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();
      expect(initAttempts, 2);
      expect(find.text('حدث خطأ في Test Feature'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      // Retry 2 (max reached)
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();
      expect(initAttempts, 3);
      expect(find.text('حدث خطأ في Test Feature'), findsOneWidget);

      // Since max retries = 2, we started at 0. So retry count hit 2.
      // Button should disappear.
      expect(find.text('إعادة المحاولة'), findsNothing);
    });

    testWidgets('Session key changes cancel ongoing operations and reject stale success', (tester) async {
      int initAttempts = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'Test Feature',
              sessionKey: 'session-1',
              onInit: () async {
                initAttempts++;
                // simulate slow init
                await Future.delayed(const Duration(milliseconds: 50));
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
              featureName: 'Test Feature',
              sessionKey: 'session-2',
              onInit: () async {
                initAttempts++;
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

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
              onInit: () async {
                throw const MissingDictionaryFailure();
              },
              child: const Text('Success'),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('حدث خطأ في Dictionary'), findsOneWidget);
    });

    testWidgets('Critical errors immediately rethrow and fail-closed', (tester) async {
      // In Flutter tests, async exceptions that escape the widget tree
      // are caught by the Zone error handler or FlutterError.onError.
      // We can use runZonedGuarded to catch it.

      Object? caughtException;

      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FeatureBoundary(
                featureName: 'Storage',
                onInit: () async {
                  throw const InvalidVaultFailure();
                },
                child: const Text('Success'),
              ),
            ),
          ),
        );
      }, (error, stack) {
        caughtException = error;
      });

      // Since pump() evaluates the async initialisation
      await runZonedGuarded(() async {
         await tester.pump();
      }, (error, stack) {
        caughtException ??= error;
      });

      // Expect to catch the error and for it to be an InvalidVaultFailure
      expect(caughtException != null, true);
      // Depending on the version of flutter, it might wrap it in FlutterErrorDetails or FlutterError
      // Let's just check the string representation
      expect(caughtException.toString().contains('InvalidVaultFailure'), true);
    });
  });
}
