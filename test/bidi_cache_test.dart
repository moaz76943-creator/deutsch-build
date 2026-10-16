import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/bidi_helper.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  test('BiDi Helper - Correct Text Direction Detection', () {
    expect(BiDiHelper.getTextDirection('مرحبا'), TextDirection.rtl);
    expect(BiDiHelper.getTextDirection('Guten Tag'), TextDirection.ltr);
  });

  test('L1 Cache - Memory Store & Retrieve Verification', () {
    final cache = L1VocabularyCache();
    cache.put('de', [{'word': 'Buch'}]);
    expect(cache.has('de'), isTrue);
    expect(cache.get('de')!.first['word'], 'Buch');
  });
}
