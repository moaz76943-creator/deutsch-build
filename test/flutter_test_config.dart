import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Installs an in-memory preferences store before each test file runs.
///
/// `SharedPreferences.getInstance()` caches a completer. If that first load
/// reaches the platform channel, the channel reply never arrives under a full
/// `flutter test` run and every later awaiter hangs. Production code still
/// calls `getInstance()`; only the test binding is mocked.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await testMain();
}
