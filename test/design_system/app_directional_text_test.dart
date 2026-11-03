import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scenario in [
    (text: 'مرحبا', code: null, forced: null, direction: TextDirection.rtl),
    (text: 'Hallo', code: null, forced: null, direction: TextDirection.ltr),
    (text: 'مرحبا', code: 'de', forced: null, direction: TextDirection.ltr),
    (text: '123', code: 'ar', forced: null, direction: TextDirection.rtl),
    (text: '123', code: 'fa_IR', forced: null, direction: TextDirection.rtl),
    (
      text: 'Hallo',
      code: 'de',
      forced: TextDirection.rtl,
      direction: TextDirection.rtl
    ),
  ]) {
    testWidgets(
        'explicit language and direction preserve text isolation $scenario',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AppDirectionalText(
          scenario.text,
          languageCode: scenario.code,
          forceDirection: scenario.forced,
        ),
      ));
      final element = tester.element(find.text(scenario.text));
      expect(Directionality.of(element), scenario.direction);
    });
  }
}
