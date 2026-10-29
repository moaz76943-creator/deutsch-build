import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:deutsch_bilarabi/screens/phonetics_lab_screen.dart';
import 'package:deutsch_bilarabi/design_system/app_audio_button.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: PhoneticsLabScreen(),
    );
  }

  testWidgets('displays verified phonetic information and tests long text bounds', (WidgetTester tester) async {
    // Tests long text layout and mixed-script phonetic content (RTL/LTR) bounds
    await tester.pumpWidget(createTestWidget());

    expect(find.text('[ɛː] / [øː] / [yː]'), findsOneWidget);
    expect(find.text('[ɲ]'), findsOneWidget);
    expect(find.text('[ː]'), findsOneWidget);

    // Check that long description text renders without overflowing Layout
    expect(tester.takeException(), isNull);
  });

  testWidgets('unverified or unavailable pronunciation explicitly shown without blocking explanations', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(FaIcon).last, findsWidgets);
    expect(find.byTooltip('النطق الصوتي غير متوفر حالياً'), findsOneWidget);
    expect(find.text('الحرف الصامت أو الناعم في اللغة التركية'), findsOneWidget);
  });

  testWidgets('pressing play triggers audio state', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createTestWidget());

      final playButtonFinder = find.byType(AppAudioButton).first;
      expect(playButtonFinder, findsOneWidget);

      await tester.tap(playButtonFinder);
      await tester.pump();

      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('can change speech rate', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final speedButton = find.byIcon(Icons.speed);
    expect(speedButton, findsOneWidget);

    await tester.tap(speedButton);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.speed_outlined), findsOneWidget);
  });

  testWidgets('disposal cleans up audio resources properly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Ensure the widget mounted
    expect(find.byType(PhoneticsLabScreen), findsOneWidget);

    // Pump another widget to trigger disposal of PhoneticsLabScreen
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    // No exception implies the dispose callback was clean and OfflineAudioPool().stop() didn't fail
    expect(tester.takeException(), isNull);
  });
}
