import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/ui_v35/theme/neuro_accessibility_mode.dart';

void main() {
  testWidgets('NeuroAccessibilityMode provides value to descendants', (
    tester,
  ) async {
    bool value = false;

    await tester.pumpWidget(
      NeuroAccessibilityMode(
        isEnabled: true,
        child: Builder(
          builder: (context) {
            value = NeuroAccessibilityMode.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(value, isTrue);
  });

  testWidgets('NeuroAccessibilityMode fallback to false if not found', (
    tester,
  ) async {
    bool value = true;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          value = NeuroAccessibilityMode.of(context);
          return const SizedBox.shrink();
        },
      ),
    );

    expect(value, isFalse);
  });
}
