import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// التحقق من تواقيع الحزم الرقمية بواسطة خوارزمية Ed25519 (Study 06 / RFC 8032)
/// يضمن أصالة الحزم التعليمية ومطابقتها للمصدر المعتمد بدون اعتماد على مكتبات C أصلية
class Ed25519SignatureVerifier {
  static final BigInt _q = (BigInt.one << 255) - BigInt.from(19);
  static final BigInt _l = (BigInt.one << 252) +
      BigInt.parse('27742317777372353535851937790883648493');

  static final BigInt _d = _mod(
    BigInt.from(-121665) * _inv(BigInt.from(121666)),
  );

  static final BigInt _i = _modPow(BigInt.from(2), (_q - BigInt.one) >> 2, _q);

  static final BigInt _by = _mod(BigInt.from(4) * _inv(BigInt.from(5)));
  static final BigInt _bx = _xRecover(_by);

  static final _EdwardsPoint _bPoint = _EdwardsPoint(_bx, _by);

  static BigInt _mod(BigInt a) {
    var res = a % _q;
    if (res.isNegative) res += _q;
    return res;
  }

  static BigInt _modPow(BigInt base, BigInt exp, BigInt m) {
    var b = base % m;
    var e = exp;
    var result = BigInt.one;
    while (e > BigInt.zero) {
      if (e.isOdd) result = (result * b) % m;
      b = (b * b) % m;
      e >>= 1;
    }
    return result;
  }

  static BigInt _inv(BigInt a) => _modPow(a, _q - BigInt.two, _q);

  static BigInt _xRecover(BigInt y) {
    final xx = (y * y - BigInt.one) * _inv(_d * y * y + BigInt.one);
    var x = _modPow(xx, (_q + BigInt.from(3)) >> 3, _q);
    if (_mod(x * x - xx) != BigInt.zero) {
      x = _mod(x * _i);
    }
    if (_mod(x * x - xx) != BigInt.zero) {
      throw const FormatException('Cannot recover x on Curve25519');
    }
    if (x.isOdd) x = _q - x;
    return x;
  }

  static BigInt _decodeLittleEndian(List<int> bytes) {
    var sum = BigInt.zero;
    for (var i = 0; i < bytes.length; i++) {
      sum += BigInt.from(bytes[i]) << (i * 8);
    }
    return sum;
  }

  static _EdwardsPoint _decodePoint(Uint8List bytes) {
    if (bytes.length != 32) throw const FormatException('Invalid point length');
    final lastByte = bytes[31];
    final sign = (lastByte & 0x80) != 0;
    final yBytes = Uint8List.fromList(bytes);
    yBytes[31] &= 0x7F;

    final y = _decodeLittleEndian(yBytes);
    if (y >= _q) throw const FormatException('y coordinate out of field');
    var x = _xRecover(y);
    if (x.isOdd != sign) {
      x = _q - x;
    }
    return _EdwardsPoint(x, y);
  }

  /// التحقق من توقيع Ed25519 (64 بايت) لرسالة أو حزمة
  static bool verify({
    required Uint8List publicKeyBytes,
    required Uint8List messageBytes,
    required Uint8List signatureBytes,
  }) {
    try {
      if (publicKeyBytes.length != 32 || signatureBytes.length != 64) {
        return false;
      }

      final rBytes = signatureBytes.sublist(0, 32);
      final sBytes = signatureBytes.sublist(32, 64);
      final s = _decodeLittleEndian(sBytes);

      if (s >= _l || s < BigInt.zero) return false;

      final aPoint = _decodePoint(publicKeyBytes);
      final rPoint = _decodePoint(rBytes);

      // k = SHA512(R || A || M)
      final hashInput = Uint8List(32 + 32 + messageBytes.length);
      hashInput.setRange(0, 32, rBytes);
      hashInput.setRange(32, 64, publicKeyBytes);
      hashInput.setRange(64, hashInput.length, messageBytes);

      final digest = sha512.convert(hashInput);
      final k = _decodeLittleEndian(digest.bytes) % _l;

      // Check s*B == R + k*A
      final sb = _scalarMult(_bPoint, s);
      final ka = _scalarMult(aPoint, k);
      final rPlusKa = _addPoints(rPoint, ka);

      return sb.x == rPlusKa.x && sb.y == rPlusKa.y;
    } catch (_) {
      return false;
    }
  }

  static _EdwardsPoint _addPoints(_EdwardsPoint p1, _EdwardsPoint p2) {
    final x1 = p1.x, y1 = p1.y, x2 = p2.x, y2 = p2.y;
    final dX1X2Y1Y2 = _mod(_d * x1 * x2 * y1 * y2);
    final x3 = _mod((x1 * y2 + y1 * x2) * _inv(BigInt.one + dX1X2Y1Y2));
    final y3 = _mod((y1 * y2 + x1 * x2) * _inv(BigInt.one - dX1X2Y1Y2));
    return _EdwardsPoint(x3, y3);
  }

  static _EdwardsPoint _scalarMult(_EdwardsPoint p, BigInt scalar) {
    var r = _EdwardsPoint(BigInt.zero, BigInt.one); // neutral element
    var q = p;
    var s = scalar;
    while (s > BigInt.zero) {
      if (s.isOdd) r = _addPoints(r, q);
      q = _addPoints(q, q);
      s >>= 1;
    }
    return r;
  }
}

class _EdwardsPoint {
  final BigInt x;
  final BigInt y;
  const _EdwardsPoint(this.x, this.y);
}

/// سجل المفاتيح العامة المعتمدة ومفاتيح الناشرين الموثوقين
class PackTrustRegistry {
  /// مفاتيح عامة معروفة من اختبارات RFC 8032 حيث مفاتيحها الخاصة معروفة للعامة.
  /// يحظر تماماً قبول هذه المفاتيح في بيئة الإنتاج أو تفويض حزم تعليمية من خلالها.
  static const Set<String> knownInsecureTestKeys = {
    // RFC 8032 Test Vector 1
    'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
    // RFC 8032 Test Vector 2
    '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c',
    // RFC 8032 Test Vector 3
    'fc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025',
  };

  // المفاتيح الرسمية المعتمدة - لا تتضمن أي مفاتيح اختبار أو مفاتيح خاصة
  static final Map<String, String> _trustedPublicKeys = {};
  static final Set<String> _revokedKeyFingerprints = {};

  /// فحص ما إذا كان المفتاح موثوقاً ومعتمداً
  /// في بيئة الإنتاج يرفض تماماً أي مفتاح اختبار عام معروف
  static bool isKeyTrusted(String keyHex) {
    final normalized = keyHex.trim().toLowerCase();
    // مفاتيح الاختبار العامة مرفوضة قطعياً في بيئة الإنتاج
    if (knownInsecureTestKeys.contains(normalized)) {
      return false;
    }
    if (_revokedKeyFingerprints.contains(normalized)) return false;
    return _trustedPublicKeys.values.contains(normalized);
  }

  /// تسجيل مفتاح ناشر موثوق
  static void registerTrustedKey(String publisherId, String publicKeyHex) {
    final normalized = publicKeyHex.trim().toLowerCase();
    if (knownInsecureTestKeys.contains(normalized)) {
      throw ArgumentError(
        'Security Error: Cannot register publicly known RFC 8032 test key in production registry',
      );
    }
    _trustedPublicKeys[publisherId] = normalized;
  }

  /// إلغاء الثقة في مفتاح عام محدد
  static void revokeKey(String publicKeyHex) {
    _revokedKeyFingerprints.add(publicKeyHex.trim().toLowerCase());
  }

  /// تسجيل مفتاح مخصص للاختبارات المعزولة فقط (يحظر في بيئة Release)
  @visibleForTesting
  static void registerTestKeyForTesting(String publisherId, String publicKeyHex) {
    if (kReleaseMode) {
      throw StateError('Cannot register test keys in release mode');
    }
    _trustedPublicKeys[publisherId] = publicKeyHex.trim().toLowerCase();
  }

  /// فحص موثوقية المفتاح في بيئة الاختبار
  @visibleForTesting
  static bool isKeyTrustedForTesting(String keyHex) {
    final normalized = keyHex.trim().toLowerCase();
    if (_revokedKeyFingerprints.contains(normalized)) return false;
    return _trustedPublicKeys.values.contains(normalized);
  }

  /// مسح سجل المفاتيح لإعادة التهيئة في الاختبارات
  @visibleForTesting
  static void clearRegistryForTesting() {
    _trustedPublicKeys.clear();
    _revokedKeyFingerprints.clear();
  }

  static Uint8List? hexToBytes(String hex) {
    if (hex.length.isOdd) return null;
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      final part = hex.substring(i * 2, i * 2 + 2);
      final byte = int.tryParse(part, radix: 16);
      if (byte == null) return null;
      bytes[i] = byte;
    }
    return bytes;
  }
}
