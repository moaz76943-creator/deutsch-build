import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/features/exercises/presentation/widgets/bidiflex_interactive_widget.dart';

void main() {
  group('BidiFlexInteractiveWidget Widget Tests', () {
    testWidgets('renders both Arabic RTL and German LTR segments without error', (tester) async {
      final segments = [
        BidiSegment.arabic('اختر المعنى الصحيح لكلمة:'),
        BidiSegment.german('Handschuh'),
        BidiSegment.arabic('في الجملة التالية.'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiFlexInteractiveWidget(
              segments: segments,
            ),
          ),
        ),
      );

      expect(find.text('اختر المعنى الصحيح لكلمة:'), findsOneWidget);
      expect(find.text('Handschuh'), findsOneWidget);
      expect(find.text('في الجملة التالية.'), findsOneWidget);
    });

    testWidgets('renders interactive slot using slotBuilder callback', (tester) async {
      final segments = [
        BidiSegment.arabic('أكمل الفراغ:'),
        BidiSegment.german('Ich gehe in ___ Schule.', isSlot: true, key: 'slot_1'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiFlexInteractiveWidget(
              segments: segments,
              slotBuilder: (context, seg) {
                return Chip(label: Text(seg.slotKey ?? 'slot'));
              },
            ),
          ),
        ),
      );

      expect(find.text('slot_1'), findsOneWidget);
      expect(find.text('أكمل الفراغ:'), findsOneWidget);
    });
  });
}
