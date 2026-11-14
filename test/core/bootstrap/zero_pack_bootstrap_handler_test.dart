import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/bootstrap/zero_pack_bootstrap_handler.dart';

void main() {
  group('ZeroPackBootstrapHandler Resilience Tests', () {
    late Directory tempPacksDir;

    setUp(() async {
      tempPacksDir = await Directory.systemTemp.createTemp('zero_pack_test_');
    });

    tearDown(() async {
      if (await tempPacksDir.exists()) {
        await tempPacksDir.delete(recursive: true);
      }
    });

    test('Safely routes to onboarding without throwing when pack directory is empty (cold boot)', () async {
      final handler = ZeroPackBootstrapHandler(
        activePacksDir: tempPacksDir,
        onboardingRoute: '/pack_onboarding',
      );

      final result = await handler.evaluatePacksAndResolveRoute();

      expect(result.discoveredPackCount, equals(0));
      expect(result.resolution, equals(ZeroPackResolution.catalogNavigationRequired));
      expect(result.targetRoute, equals('/pack_onboarding'));
      expect(result.isSafeToProceed, isTrue);
    });

    test('Routes to main dashboard when valid installed packs exist', () async {
      // Simulate existing installed pack
      final mockPack = File('${tempPacksDir.path}/de_ar_a1.pack');
      await mockPack.writeAsString('mock_content');

      final handler = ZeroPackBootstrapHandler(
        activePacksDir: tempPacksDir,
        mainDashboardRoute: '/dashboard',
      );

      final result = await handler.evaluatePacksAndResolveRoute();

      expect(result.discoveredPackCount, equals(1));
      expect(result.resolution, equals(ZeroPackResolution.activePacksFound));
      expect(result.targetRoute, equals('/dashboard'));
    });
  });
}
