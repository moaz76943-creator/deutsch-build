import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  testWidgets('FeatureBoundary يعرض المحتوى عند عدم وجود خطأ', (tester) async {
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

  testWidgets('FeatureBoundary يلتقط الأخطاء غير الحرجة ويعرض الواجهة البديلة', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureBoundary(
            featureName: 'اختبار الحماية',
            child: Container(key: key, child: const Text('الميزة تعمل بشكل سليم')),
          ),
        ),
      ),
    );

    FeatureBoundary.of(key.currentContext!)!.reportError(Exception('Network error'));
    await tester.pumpAndSettle();

    expect(find.text('تعذر تشغيل اختبار الحماية'), findsOneWidget);
  });

  testWidgets('FeatureBoundary يُمرر الأخطاء الحرجة للأعلى', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureBoundary(
            featureName: 'اختبار الحماية',
            child: Container(key: key, child: const Text('الميزة تعمل بشكل سليم')),
          ),
        ),
      ),
    );

    expect(
      () => FeatureBoundary.of(key.currentContext!)!.reportError(const StorageFailure('E1', 'Storage corrupted vault')),
      throwsA(isA<StorageFailure>()),
    );
  });
}
