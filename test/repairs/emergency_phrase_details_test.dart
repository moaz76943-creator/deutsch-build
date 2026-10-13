import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/emergency_phrasebook_screen.dart';

void main() {
  testWidgets('offline emergency phrase opens matching detail and returns',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EmergencyPhrasebookScreen()),
    );

    await tester.tap(find.text('أحتاج إلى طبيب فوراً'));
    await tester.pumpAndSettle();

    expect(find.byType(EmergencyPhrasebookDetailScreen), findsOneWidget);
    expect(find.text('Ich brauche sofort einen Arzt'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(EmergencyPhrasebookDetailScreen), findsNothing);
    expect(find.text('أين أقرب صيدلية؟'), findsOneWidget);
  });

  testWidgets('phrase options announce accessible button intent',
      (tester) async {
    final handle = tester.ensureSemantics();
    addTearDown(handle.dispose);
    await tester.pumpWidget(
      const MaterialApp(home: EmergencyPhrasebookScreen()),
    );
    expect(find.bySemanticsLabel(RegExp(r'أحتاج إلى طبيب')), findsWidgets);
    final semanticsWidgets = find.ancestor(
      of: find.text('أحتاج إلى طبيب فوراً'),
      matching: find.byType(Semantics),
    );
    expect(semanticsWidgets, findsWidgets);
  });

  testWidgets('detail remains overflow-safe on a narrow RTL scaled screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 520);
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
        home: const EmergencyPhrasebookScreen(),
      ),
    );

    await tester.tap(find.text('أحتاج إلى طبيب فوراً'));
    await tester.pumpAndSettle();

    expect(find.byType(EmergencyPhrasebookDetailScreen), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
