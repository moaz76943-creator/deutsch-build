import 'dart:io';
import 'package:flutter/foundation.dart';

class DatabaseBootstrapResult {
  final bool isReady;
  final String? error;

  const DatabaseBootstrapResult({required this.isReady, this.error});
}

class DatabaseBootstrapper {
  /// التحقق من سلامة وجود قاعدة البيانات دون شروط حجم اعتباطية
  static Future<DatabaseBootstrapResult> verifyAndPrepare({
    required String dbPath,
    Future<void> Function()? onSeedRequired,
  }) async {
    try {
      final file = File(dbPath);

      if (!await file.exists()) {
        if (onSeedRequired != null) {
          debugPrint('[Bootstrap] قاعدة البيانات غير موجودة، بدء التثبيت الأولي...');
          await onSeedRequired();
        } else {
          return const DatabaseBootstrapResult(
            isReady: false,
            error: 'Database file missing and no seeder provided',
          );
        }
      }

      // فحص أولي لوجود ترويسة SQLite القياسية (SQLite format 3)
      if (await file.exists()) {
        final length = await file.length();
        if (length < 16) {
          return const DatabaseBootstrapResult(
            isReady: false,
            error: 'Database file corrupted or truncated',
          );
        }

        final raf = await file.open(mode: FileMode.read);
        final header = await raf.read(16);
        await raf.close();

        final magicString = String.fromCharCodes(header);
        if (!magicString.startsWith('SQLite format 3')) {
          return const DatabaseBootstrapResult(
            isReady: false,
            error: 'Invalid SQLite header signature',
          );
        }
      }

      return const DatabaseBootstrapResult(isReady: true);
    } catch (e, stack) {
      debugPrint('[Bootstrap Error] فشل تهيئة قاعدة البيانات: $e\n$stack');
      return DatabaseBootstrapResult(isReady: false, error: e.toString());
    }
  }
}
