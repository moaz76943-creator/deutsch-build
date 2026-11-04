/// Task 1738: Symmetric int8 affine scale and zero-point tensor packer
class SymmetricQuantizationPacker {
  int quantize(double val, double scale) => (val / scale).round().clamp(-128, 127);
}
