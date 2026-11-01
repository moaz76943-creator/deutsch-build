class Float16QuantizedMath {
  static int toF16(double val) => val.clamp(-65504.0, 65504.0).toInt();
}
