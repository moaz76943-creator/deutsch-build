import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/resilience/resilient_feature_executor.dart';
import 'package:deutsch_bilarabi/core/resilience/recovery_outcome.dart';
import 'package:deutsch_bilarabi/core/concurrency/cancellation_token.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  group('ResilientFeatureExecutor', () {
    test('ينفذ العملية بنجاح من المحاولة الأولى', () async {
      final executor = ResilientFeatureExecutor();
      final outcome = await executor.execute(task: () async => 'success');

      expect(outcome.isSuccess, isTrue);
      expect(outcome.data, 'success');
    });

    test('يعيد المحاولة عند الفشل المؤقت ثم ينجح', () async {
      final executor = ResilientFeatureExecutor();
      int attempts = 0;
      final outcome = await executor.execute(
        task: () async {
          attempts++;
          if (attempts < 3) throw Exception('Temporary network failure');
          return 'success after retry';
        },
        maxAttempts: 3,
        backoff: const Duration(milliseconds: 10),
      );

      expect(outcome.isSuccess, isTrue);
      expect(outcome.data, 'success after retry');
      expect(attempts, 3);
    });

    test('يتوقف بعد استنفاد محاولات إعادة المحاولة', () async {
      final executor = ResilientFeatureExecutor();
      int attempts = 0;
      final outcome = await executor.execute(
        task: () async {
          attempts++;
          throw Exception('Persistent failure');
        },
        maxAttempts: 2,
        backoff: const Duration(milliseconds: 10),
      );

      expect(outcome.isFailed, isTrue);
      expect(attempts, 2);
    });

    test('يرفض النتيجة القديمة عند تغير الجلسة', () async {
      final executor = ResilientFeatureExecutor();
      final outcomeFuture = executor.execute(
        task: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'delayed success';
        },
      );

      // Simulate a session change before the task completes
      executor.resetSession();

      final outcome = await outcomeFuture;
      expect(outcome.isStale, isTrue);
      expect(outcome.data, isNull);
    });

    test('يُلغي العملية بنجاح عند استخدام CancellationToken', () async {
      final executor = ResilientFeatureExecutor();
      final token = CancellationToken();

      final outcomeFuture = executor.execute(
        task: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'success';
        },
        cancellationToken: token,
      );

      token.cancel();

      final outcome = await outcomeFuture;
      expect(outcome.isCancelled, isTrue);
    });

    test('يمرر الأخطاء الحرجة بدون إعادة محاولة', () async {
      final executor = ResilientFeatureExecutor();
      int attempts = 0;

      expect(
        () => executor.execute(
          task: () async {
            attempts++;
            throw const StorageFailure('E1', 'Storage full');
          },
          maxAttempts: 3,
        ),
        throwsA(isA<StorageFailure>()),
      );

      // Wait a moment to ensure no retries are happening
      await Future.delayed(const Duration(milliseconds: 50));
      expect(attempts, 1);
    });

    test('يعتبر فقدان المعجم أو الحزمة اختياري (غير حرج)', () {
      expect(FailureCategorization.isCritical(Exception('Missing plugin TTS')), isFalse);
      expect(FailureCategorization.isRecoverable(Exception('Dictionary unavailable')), isTrue);
    });

    test('يعتبر أخطاء القبو (vault) حرجة', () {
      expect(FailureCategorization.isCritical(Exception('vault corruption')), isTrue);
      expect(FailureCategorization.isCritical(Exception('data integrity check failed')), isTrue);
    });
  });
}
