/// Task 1714: Fallback UTF-8 byte sequence mapper for untokenizable characters
class ByteFallbackMapper {
  List<int> toUtf8Bytes(String token) => token.codeUnits;
}
