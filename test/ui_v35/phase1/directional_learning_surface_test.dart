import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/ui_v35/phase1/directional_learning_surface.dart';

void main() {
  const surfaceKey = Key('phase1-directional-surface');
  const contentKey = Key('phase1-directional-content');

  Future<({Rect surface, Rect content})> pumpSurface(
    WidgetTester tester,
    TextDirection direction,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: Directionality(
                textDirection: direction,
                child: const DirectionalLearningSurface(
                  key: surfaceKey,
                  child: SizedBox(
                    key: contentKey,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return (
      surface: tester.getRect(find.byKey(surfaceKey)),
      content: tester.getRect(find.byKey(contentKey)),
    );
  }

  testWidgets('start padding and start alignment mirror between LTR and RTL',
      (tester) async {
    final ltr = await pumpSurface(tester, TextDirection.ltr);
    final rtl = await pumpSurface(tester, TextDirection.rtl);

    expect(ltr.content.left - ltr.surface.left, 24);
    expect(rtl.surface.right - rtl.content.right, 24);
    expect(ltr.content.center.dx, lessThan(ltr.surface.center.dx));
    expect(rtl.content.center.dx, greaterThan(rtl.surface.center.dx));
  });

  testWidgets('surface exposes directional padding and alignment geometry',
      (tester) async {
    await pumpSurface(tester, TextDirection.rtl);

    final padding = tester.widget<Padding>(
      find.byKey(const Key('phase1-directional-padding')),
    );
    final align = tester.widget<Align>(
      find.byKey(const Key('phase1-directional-align')),
    );

    expect(padding.padding, isA<EdgeInsetsDirectional>());
    expect(align.alignment, isA<AlignmentDirectional>());
  });
}
