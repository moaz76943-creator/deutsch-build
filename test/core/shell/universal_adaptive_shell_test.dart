import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/contracts/linguistic_capability.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';
import 'package:deutsch_bilarabi/core/shell/interaction_mode.dart';
import 'package:deutsch_bilarabi/core/shell/universal_adaptive_shell.dart';

UniversalScenarioContract<String> scenario(String id) =>
    UniversalScenarioContract<String>(
      scenarioId: id,
      languagePair: const LanguagePair(sourceIso: 'ar', targetIso: 'de'),
      requiredCapabilities: const {LinguisticCapability.syntacticBranching},
      acceptedAnswers: const ['hallo'],
      localExplanation: 'تم التحقق',
      payload: 'offline-only',
      isLinguisticallyVerified: true,
    );

void main() {
  for (final mode in InteractionMode.values) {
    testWidgets('verified $mode accepts an answer and evaluates locally',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UniversalAdaptiveShell(
          contract: scenario('verified-$mode'),
          mode: mode,
        ),
      ));

      final answer = find.byKey(const Key('universal_scenario_answer'));
      final submit = find.widgetWithText(FilledButton, 'تحقق محلياً');

      expect(answer, findsOneWidget);
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);

      await tester.enterText(answer, 'hallo');
      await tester.pump();
      expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);

      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('تم التحقق'), findsOneWidget);
    });
  }

  testWidgets('changing the contract clears stale answer and result',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: UniversalAdaptiveShell(
        contract: scenario('first'),
        mode: InteractionMode.maskedInspection,
      ),
    ));
    final answer = find.byKey(const Key('universal_scenario_answer'));
    final submit = find.widgetWithText(FilledButton, 'تحقق محلياً');

    await tester.enterText(answer, 'hallo');
    await tester.pump();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('تم التحقق'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: UniversalAdaptiveShell(
        contract: scenario('second'),
        mode: InteractionMode.maskedInspection,
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(answer).controller!.text, isEmpty);
    expect(find.text('تم التحقق'), findsNothing);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
  });

  for (final width in [320.0, 360.0, 393.0, 430.0]) {
    testWidgets('$width px at 200% font scale keeps submit reachable',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 430));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
          ),
          child: child!,
        ),
        home: UniversalAdaptiveShell(
          contract: scenario('small-$width'),
          mode: InteractionMode.kineticBlocks,
        ),
      ));

      final answer = find.byKey(const Key('universal_scenario_answer'));
      await tester.enterText(answer, 'hallo');
      await tester.pump();
      final submit = find.widgetWithText(FilledButton, 'تحقق محلياً');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('تم التحقق'), findsOneWidget);
    });
  }
}
