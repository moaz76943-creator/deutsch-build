import 'dart:typed_data';

class FfiNativeBufferBridge {
  final int pointerAddress;
  const FfiNativeBufferBridge({this.pointerAddress = 0});
  Uint8List asTypedView(int length) => Uint8List(length);
}
