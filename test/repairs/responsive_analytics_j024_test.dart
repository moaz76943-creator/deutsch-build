import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/analytics_screen.dart';
import 'package:deutsch_bilarabi/screens/performance_analytics_screen.dart';

void main() {
  Future<void> atNarrowLargeScale(
    WidgetTester tester,
    Widget screen,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2.5),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
        home: screen,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets('analytics is responsive at 320px RTL / 250% text',
      (tester) async {
    await atNarrowLargeScale(tester, const AnalyticsScreen());
    // The graph intentionally scrolls horizontally rather than compressing
    // labels into unreadable glyphs or overflowing its card.
    final horizontal = find.byWidgetPredicate(
      (widget) => widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    expect(horizontal, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('performance weakness labels wrap at 320px / 250% text',
      (tester) async {
    await atNarrowLargeScale(tester, const PerformanceAnalyticsScreen());
    expect(find.textContaining('معدل التقدم العام'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
