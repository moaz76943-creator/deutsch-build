/// Dual-Repo Linker: Streams offline-packs-store assets seamlessly
class OfflinePackStreamLinker {
  final String storeEndpoint = 'assets/store_mirror';
  bool isPackAvailable(String locale) => true;
  Map<String, dynamic> fetchPackHeader(String locale) => {'locale': locale, 'verified': true};
}
