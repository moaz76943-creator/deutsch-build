/// Task 1218: Sanitization and strict enforcement of ZWNJ and ZWJ
class ZwnjSanitizer {
  bool isZwnj(int code) => code == 0x200C;
  bool isZwj(int code) => code == 0x200D;
}
