import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// بوابة الفحص الأمني للحزم لمنع دخول ملفات تالفة أو خبيثة
class PackAdmissionService {
  
  /// التحقق من سلامة الحزمة قبل اعتمادها (SHA-256)
  static Future<bool> verifyAndAdmitPack(File stagedFile, String expectedHash) async {
    try {
      final bytes = await stagedFile.readAsBytes();
      final digest = sha256.convert(bytes);
      
      if (digest.toString() == expectedHash) {
        debugPrint("تم التحقق من الحزمة بنجاح. جاري النقل الذري...");
        // النقل الذري (Atomic Rename) يتم هنا في التنفيذ الفعلي
        return true;
      }
      debugPrint("فشل التحقق: الحزمة تالفة أو غير موثوقة.");
      return false;
    } catch (e) {
      debugPrint("خطأ أثناء فحص الحزمة: \$e");
      return false;
    }
  }
}
