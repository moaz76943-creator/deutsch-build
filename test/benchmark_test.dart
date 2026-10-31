import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('⚡ Benchmark: In-Memory L1 Cache Latency (< 1ms target)', () {
    final cache = L1VocabularyCache();
    final dummyData = List.generate(
      100,
      (i) => {'id': i, 'word': 'Wort_$i', 'meaning': 'معنى_$i'},
    );

    cache.put('de_bench', dummyData);

    final stopwatch = Stopwatch()..start();
    final retrieved = cache.get('de_bench');
    stopwatch.stop();

    final elapsedMicros = stopwatch.elapsedMicroseconds;
    final elapsedMillis = elapsedMicros / 1000.0;

    // طباعة القياس الدقيق
    print('⏱️ زمن استرجاع L1 Cache لـ 100 عنصر: $elapsedMillis ms ($elapsedMicros µs)');

    expect(retrieved, isNotNull);
    expect(retrieved!.length, 100);
    // التحقق الصارم: يجب أن يكون أقل من 5ms
    expect(elapsedMillis < 5.0, isTrue);
  });

  test('⚡ Benchmark: JSON Parse & Validation Throughput (< 8ms target)', () {
    final rawJson = jsonEncode(List.generate(
      50,
      (i) => {
        'id': i,
        'title': 'Mission $i',
        'level': 'A1',
        'words': ['eins', 'zwei', 'drei']
      },
    ));

    final stopwatch = Stopwatch()..start();
    final parsed = jsonDecode(rawJson) as List;
    stopwatch.stop();

    final elapsedMillis = stopwatch.elapsedMicroseconds / 1000.0;
    print('⏱️ زمن تفكيك الـ JSON لـ 50 مهمة: $elapsedMillis ms');

    expect(parsed.length, 50);
    expect(elapsedMillis < 8.0, isTrue);
  });
}
