import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/screens/onboarding_screen.dart';

void main() {
  testWidgets('a stalled progress read exposes retry and preserves onboarding',
      (tester) async {
    var attempts = 0;
    final neverCompletes = Completer<int>();

    Future<int> readProgressCount() {
      attempts++;
      if (attempts == 1) return neverCompletes.future;
      return Future<int>.value(0);
    }

    await tester.pumpWidget(MaterialApp(
      home: FastOnboardingScreen(readReviewCount: readProgressCount),
    ));
    await tester.pump(const Duration(seconds: 9));
    await tester.pump();

    expect(find.text('تعذر فتح سجل التقدّم المحلي.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump();

    expect(attempts, 2);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
