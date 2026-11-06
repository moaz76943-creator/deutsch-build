import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/innovation_wave_01/innovation_hub_screen.dart';

void main() {
  testWidgets('InnovationHubScreen SegmentedButton tests', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: InnovationHubScreen(),
    ));
    await tester.pumpAndSettle();

    // Scroll down to make the segmented button visible
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('الدلالة: أنا الشخص الوحيد الذي دعا آنا (لم يدعُها غيري).'), findsOneWidget);
    expect(find.text('الدلالة: دعوت آنا بمفردها (لم أدعُ أي شخص آخر).'), findsNothing);

    // Tap sentence_b
    await tester.tap(find.text('Ich habe nur Anna eingeladen'));
    await tester.pumpAndSettle();

    // Verify new state
    expect(find.text('الدلالة: أنا الشخص الوحيد الذي دعا آنا (لم يدعُها غيري).'), findsNothing);
    expect(find.text('الدلالة: دعوت آنا بمفردها (لم أدعُ أي شخص آخر).'), findsOneWidget);
  });
}
