import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/dynamic_ui_variations.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DynamicUiVariationsEngine.instance.close();
  });

  test(
    'DynamicUiVariationsEngine generates and retrieves daily seed',
    () async {
      final engine = DynamicUiVariationsEngine.instance;

      // First call should generate a seed
      final seed1 = await engine.getDailySeed();
      expect(seed1, greaterThanOrEqualTo(0));
      expect(seed1, lessThan(360));

      // Second call on the same day should return the same seed
      final seed2 = await engine.getDailySeed();
      expect(seed1, equals(seed2));
    },
  );
}
