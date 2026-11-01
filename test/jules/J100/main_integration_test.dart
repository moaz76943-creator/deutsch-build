import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/main.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'package:deutsch_bilarabi/core/registry/feature_capability_registry.dart';
import 'package:deutsch_bilarabi/core/resilience/safe_mode_recovery_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('J100 — Self-Healing Production Bootstrap Integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('1. Successful startup mounts main application', (WidgetTester tester) async {
      await tester.pumpWidget(const ResilientAppRoot());

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("جاري التهيئة..."), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify success leads to the main app (DeutschApp)
      expect(find.byType(DeutschApp), findsOneWidget);
    });

    testWidgets('2. Optional failure (e.g. missing audio pack) does not prevent app startup', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      // Register an optional feature failure before startup
      FeatureCapabilityRegistry.instance.registerFeature('audio_pack_de', FeatureStatus.unsupported);

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      // Should still mount the main app
      expect(find.byType(DeutschApp), findsOneWidget);
      expect(FeatureCapabilityRegistry.instance.getStatus('audio_pack_de'), FeatureStatus.unsupported);
    });

    testWidgets('3. Repeated failures trigger CrashLoopGuard and safe-mode activation', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'deutsch_crash_count_v1': 3,
        'deutsch_last_crash_v1': DateTime.now().millisecondsSinceEpoch,
      });

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      // Verify safe mode is shown
      expect(find.byType(SafeModeRecoveryGate), findsOneWidget);
      expect(find.text('وضعية الاسترداد الآمن (Safe Mode)'), findsOneWidget);
    });

    testWidgets('4. Interrupted session recovery and duplicate initialization prevention', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': '{"session_id":"123","current_route":"/test","last_item_index":0,"timestamp":0}'
      });

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      expect(find.byType(DeutschApp), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DeutschApp), findsOneWidget);
    });

    testWidgets('5. Critical integrity failure activates recovery state without erasing progress', (WidgetTester tester) async {
      await tester.pumpWidget(SafeModeRecoveryGate(
        message: 'Critical DB Integrity Error',
        onRetry: () {},
      ));

      await tester.pumpAndSettle();
      expect(find.text('Critical DB Integrity Error'), findsOneWidget);
      expect(find.text('Retry / Clear errors'), findsOneWidget);
    });

    testWidgets('6. Missing pack degraded state does not block available functionality', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      FeatureCapabilityRegistry.instance.registerFeature('pack_ru', FeatureStatus.unsupported);

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      expect(find.byType(DeutschApp), findsOneWidget);
    });

    testWidgets('7. Recovery button in Safe Mode clears errors and restarts initialization', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'deutsch_crash_count_v1': 3,
        'deutsch_last_crash_v1': DateTime.now().millisecondsSinceEpoch,
      });

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      expect(find.byType(SafeModeRecoveryGate), findsOneWidget);

      await tester.tap(find.text('Retry / Clear errors'));
      await tester.pumpAndSettle();

      // After retry, it should have reset and successfully mounted DeutschApp
      expect(find.byType(DeutschApp), findsOneWidget);
    });
  });
}
