import 'dart:typed_data';
class ZeroLeakageMemoryCleanserInterceptor {
  void wipeBuffer(Uint8List sensitiveBytes) => sensitiveBytes.fillRange(0, sensitiveBytes.length, 0);
}
