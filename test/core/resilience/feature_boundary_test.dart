import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';

void main() {
  testWidgets('FeatureBoundary يمنع تعطل الواجهة عند حدوث أي خطأ داخلي', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeatureBoundary(
            featureName: 'اختبار الحماية',
            child: Text('الميزة تعمل بشكل سليم'),
          ),
        ),
      ),
    );

    expect(find.text('الميزة تعمل بشكل سليم'), findsOneWidget);
  });

  testWidgets('critical async initialization is reported, never hidden as optional', (tester) async {
    Object? caughtException;
    await tester.pumpWidget(MaterialApp(
      home: FeatureBoundary(
        featureName: 'storage',
        initializationAction: () async {
          throw const StorageFailure('integrity', 'critical data store failure');
        },
        onCriticalFailure: (err, stack) {
          caughtException = err;
        },
        child: const Text('ready'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(caughtException, isA<StorageFailure>());
    expect(find.text('ready'), findsNothing);
  });

}
