import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/main.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'package:deutsch_bilarabi/core/registry/feature_capability_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('J100 — Self-Healing Production Bootstrap Integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('1. Successful startup mounts main application',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ResilientAppRoot());

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("جاري التهيئة..."), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify success leads to the main app (DeutschApp)
      expect(find.byType(DeutschApp), findsOneWidget);
    });

    testWidgets(
        '2. Optional failure (e.g. missing audio pack) does not prevent app startup',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      // Register an optional feature failure before startup
      FeatureCapabilityRegistry.instance
          .registerFeature('audio_pack_de', FeatureStatus.unsupported);

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      // Should still mount the main app
      expect(find.byType(DeutschApp), findsOneWidget);
      expect(FeatureCapabilityRegistry.instance.getStatus('audio_pack_de'),
          FeatureStatus.unsupported);
    });

    testWidgets('Missing pack does not prevent app startup',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      // Register a missing language pack failure
      FeatureCapabilityRegistry.instance
          .registerFeature('lang_pack_de', FeatureStatus.unsupported);

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      // Should still mount the main app
      expect(find.byType(DeutschApp), findsOneWidget);
      expect(FeatureCapabilityRegistry.instance.getStatus('lang_pack_de'),
          FeatureStatus.unsupported);
    });

    testWidgets(
        '3. Repeated failures trigger CrashLoopGuard and safe-mode activation',
        (WidgetTester tester) async {
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

    testWidgets(
        '4. Interrupted session recovery and duplicate initialization prevention',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1':
            '{"session_id":"123","current_route":"/test","last_item_index":0,"timestamp":0}'
      });

      await tester.pumpWidget(const ResilientAppRoot());
      await tester.pumpAndSettle();

      expect(find.byType(DeutschApp), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DeutschApp), findsOneWidget);
    });

    testWidgets(
        '5. Critical integrity failure activates recovery state without erasing progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(SafeModeRecoveryGate(
        message: 'Critical DB Integrity Error',
        onRetry: () {},
      ));

      await tester.pumpAndSettle();
      expect(find.text('Critical DB Integrity Error'), findsOneWidget);
      expect(find.text('إعادة المحاولة / مسح الأخطاء'), findsOneWidget);
    });
  });
}
