import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/ui/bidirectional_overflow_guard.dart';

void main() {
  group('Bidirectional Overflow Guard Tests', () {
    testWidgets('Renders mixed LTR/RTL pair without throwing RenderFlex overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 300,
            child: BidiFlexPair(
              sourceText: 'Das ist ein deutsches Wort',
              targetText: 'هذا نص عربي للتأكد من عدم التجاوز',
              isTargetRtl: true,
            ),
          ),
        ),
      );
      expect(find.byType(BidiFlexPair), findsOneWidget);
    });
  });
}
