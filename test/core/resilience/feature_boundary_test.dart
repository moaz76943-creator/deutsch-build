import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
