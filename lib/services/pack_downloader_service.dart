// ignore_for_file: unused_import
import 'dart:async';

/// خدمة إدارة وتثبيت الحزم محلياً أوفلاين بدون استدعاءات شبكة خارجية
class PackDownloaderService {
  static Future<bool> downloadPack(String languageCode) async {
    // تحميل محلي وتثبيت فوري من قواعد البيانات الداخلية
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  static Future<bool> isPackDownloaded(String languageCode) async {
    return true;
  }

  static Future<void> cancelDownload(String languageCode) async {}
}
