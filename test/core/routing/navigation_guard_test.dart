import 'dart:async';
import 'package:test/test.dart';
import 'package:deutsch_app/core/routing/navigation_guard.dart';

void main() {
  group('DebouncedNavigationGuard Tests', () {
    test('Allows first navigation tap and suppresses duplicate rapid taps', () async {
      final guard = DebouncedNavigationGuard(
        debounceCooldown: const Duration(milliseconds: 200),
      );

      var navigationCallCount = 0;
      final action = () async {
        navigationCallCount++;
      };

      // Dispatch 3 simultaneous taps in the exact same millisecond
      final tap1 = guard.safeNavigate(action);
      final tap2 = guard.safeNavigate(action);
      final tap3 = guard.safeNavigate(action);

      final results = await Future.wait([tap1, tap2, tap3]);

      expect(results[0], isTrue); // First tap allowed
      expect(results[1], isFalse); // Second tap debounced
      expect(results[2], isFalse); // Third tap debounced
      expect(navigationCallCount, equals(1));
    });

    test('Allows subsequent navigation after cooldown window elapses', () async {
      final guard = DebouncedNavigationGuard(
        debounceCooldown: const Duration(milliseconds: 50),
      );

      var count = 0;
      await guard.safeNavigate(() async => count++);
      expect(count, equals(1));

      // Wait for cooldown
      await Future.delayed(const Duration(milliseconds: 70));

      final secondAllowed = await guard.safeNavigate(() async => count++);
      expect(secondAllowed, isTrue);
      expect(count, equals(2));
    });

    test('Safe pop verifies canPop before popping route', () {
      final guard = DebouncedNavigationGuard();
      var popped = false;

      // When at root route (canPop = false)
      final didPopAtRoot = guard.safePop(
        canPop: false,
        popAction: () => popped = true,
      );
      expect(didPopAtRoot, isFalse);
      expect(popped, isFalse);

      // When subroute exists (canPop = true)
      final didPopAtSubroute = guard.safePop(
        canPop: true,
        popAction: () => popped = true,
      );
      expect(didPopAtSubroute, isTrue);
      expect(popped, isTrue);
    });
  });
}
