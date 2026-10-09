import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/core/streak_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Streak Engine - Initial Day Sets Streak to 1', () async {
    SharedPreferences.setMockInitialValues({});
    final result = await StreakEngine.updateDailyStreak();
    expect(result['streak'], 1);
    expect(result['freezesLeft'], 2);
  });
}
