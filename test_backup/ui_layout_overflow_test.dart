import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI Layout & Text Overflow Boundary Tests', () {
    testWidgets('Verify small screen renders without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => const Text(
                  'Deutsch بالعربي - اختبار صمود الواجهات',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Verify large accessibility text scaling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: Center(
                child: Text('اختبار الخط المكبر', maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
