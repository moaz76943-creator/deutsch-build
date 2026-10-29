import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/onboarding_screen.dart';

void main() {
  testWidgets('first-run onboarding remains usable on a small scaled display',
      (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2),
        ),
        child: child!,
      ),
      home: OnboardingScreen(onStart: () => tapped = true),
    ));

    expect(find.byType(SingleChildScrollView), findsWidgets);
    final start = find.text('ابدأ التعلم الآن');
    await tester.ensureVisible(start);
    expect(tester.takeException(), isNull);
    await tester.tap(start);
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
