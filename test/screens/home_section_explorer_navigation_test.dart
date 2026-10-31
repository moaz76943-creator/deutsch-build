import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/home_screen.dart';
import 'package:deutsch_bilarabi/features/explore/presentation/section_explorer_screen.dart';

void main() {
  testWidgets('Home keeps section exploration reachable without replacing onboarding',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HomeScreen(onNavigateToUnits: () {}),
      ),
    ));

    final explore = find.text('استكشف الأقسام');
    await tester.scrollUntilVisible(explore, 160,
        scrollable: find.byType(Scrollable).first);
    expect(explore, findsOneWidget);

    await tester.tap(explore);
    await tester.pump();
    expect(find.byType(SectionExplorerScreen), findsOneWidget);

    // Dispose the route before background content initialization completes.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
