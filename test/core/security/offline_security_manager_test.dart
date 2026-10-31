import 'dart:typed_data';
import 'package:deutsch_build/core/security/offline_security_manager.dart';

void main() {
  final secManager = OfflineSecurityManager();

  // 1. فحص محاذاة صفحات الذاكرة 16KB لـ Android 15 (16384 مضاعفاتها)
  assert(secManager.verifyPageAlignment(0) == true);
  assert(secManager.verifyPageAlignment(16384) == true);
  assert(secManager.verifyPageAlignment(32768) == true);
  assert(secManager.verifyPageAlignment(4096) == false, 'Failed: 4KB offset falsely allowed for 16KB page');

  // 2. فحص التحقق من صحة شجرة ميركل وتوقيع الحزمة
  final receipt = secManager.verifyPackAdmission(
    packId: 'de_ar_a1',
    computedMerkleRoot: 'f8deea424cb8f51039fb9c9dc44c24af4fd8daab',
    manifestMerkleRoot: 'f8deea424cb8f51039fb9c9dc44c24af4fd8daab',
    fileSizeBytes: 49152, // مضاعفات كتل التخزين (48 KB)
    hasValidSignature: true,
  );
  assert(receipt.isSignatureValid == true);
  assert(receipt.scheme == SignatureScheme.mlDsa44Hybrid);

  // 3. فحص التطهير الفوري للذاكرة (Zeroization)
  final keyBuffer = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]);
  secManager.secureZeroize(keyBuffer);
  assert(keyBuffer.every((b) => b == 0), 'Failed: Buffer not zeroized');

  print('Offline security and 16KB alignment unit assertions passed.');
}
