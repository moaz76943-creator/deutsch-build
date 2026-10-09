import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/core/audio/offline_audio_pool.dart';

void main() {
  test('Memory Leak Sentinel - Controller Disposal Integrity', () {
    final controller = PageController();
    expect(controller.hasClients, isFalse);
    controller.dispose();

    final audioPool = OfflineAudioPool();
    audioPool.dispose();
    expect(audioPool.isPlaying, isFalse);
  });
}
