import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/core/srs_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Spaced Repetition Engine (SM-2) Tests', () {
    test('Initial state starts with 0 repetitions and default ease factor', () async {
      final state = await SrsEngine.getItemState('apfel');
      expect(state.wordId, equals('apfel'));
      expect(state.repetitions, equals(0));
      expect(state.intervalDays, equals(0));
      expect(state.easeFactor, equals(2.5));
    });

    test('Rating Easy increases ease factor and schedules next review', () async {
      final updated = await SrsEngine.processReview('apfel', ReviewRating.easy);
      expect(updated.repetitions, equals(1));
      expect(updated.intervalDays, equals(4));
      expect(updated.easeFactor, greaterThan(2.5));
    });

    test('Rating Again resets interval and decreases ease factor safely', () async {
      await SrsEngine.processReview('buch', ReviewRating.easy);
      final againState = await SrsEngine.processReview('buch', ReviewRating.again);
      expect(againState.repetitions, equals(0));
      expect(againState.intervalDays, equals(0));
      expect(againState.easeFactor, greaterThanOrEqualTo(1.3));
    });
  });
}
