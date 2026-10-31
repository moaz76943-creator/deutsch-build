import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_pitch_tracker.dart';

void main() {
  group('OfflinePitchTracker Tests', () {
    test('1. بوابة عزل الصمت التام تعيد 0.0 هرتز', () {
      final silence = Float32List(1600); // 100ms of zeros
      final pitch = OfflinePitchTracker.estimatePitch(silence);
      expect(pitch, equals(0.0));
    });

    test('2. بوابة عزل الضوضاء الخافتة دون العتبة تعيد 0.0 هرتز', () {
      final noise = Float32List(1600);
      for (int i = 0; i < noise.length; i++) {
        noise[i] = 0.005; // energy = 0.000025 < 0.001
      }
      final pitch = OfflinePitchTracker.estimatePitch(noise);
      expect(pitch, equals(0.0));
    });

    test('3. إشارة جيبية نقية (Sine Wave at 200 Hz) مع عينات كافية', () {
      const sampleRate = 16000;
      const targetFreq = 200.0;
      final samples = Float32List(1600); // 100ms
      for (int i = 0; i < samples.length; i++) {
        samples[i] = (0.8 * math.sin(2.0 * math.pi * targetFreq * i / sampleRate)).toDouble();
      }

      final estimated = OfflinePitchTracker.estimatePitch(samples, sampleRate: sampleRate);
      // يجب أن يكون التقدير قريب جداً من 200.0 هرتز
      expect(estimated, closeTo(200.0, 5.0));
    });

    test('4. مطابقة المنحنى اللحني للسؤال الاستفهامي الصاعد (Rising Intonation)', () {
      final userRising = <double>[150.0, 165.0, 180.0, 210.0, 240.0];
      final nativeRising = <double>[145.0, 160.0, 175.0, 205.0, 235.0];

      final score = OfflinePitchTracker.matchIntonation(userRising, nativeRising);
      expect(score, greaterThanOrEqualTo(0.85));
    });

    test('5. كشف تباين النبرة عند اختلاف الاتجاه (صاعد مقابل هابط)', () {
      final userFalling = <double>[240.0, 210.0, 180.0, 160.0, 140.0];
      final nativeRising = <double>[140.0, 160.0, 180.0, 210.0, 240.0];

      final score = OfflinePitchTracker.matchIntonation(userFalling, nativeRising);
      expect(score, lessThan(0.60));
    });

    test('6. معالجة القوائم الفارغة', () {
      expect(OfflinePitchTracker.estimatePitch(Float32List(0)), equals(0.0));
      expect(OfflinePitchTracker.matchIntonation([], []), equals(0.0));
    });
  });
}
