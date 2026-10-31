/// Database lifecycle boundary used by pack storage without importing
/// the database service, preventing service-layer import cycles.
typedef DatabaseCloserCallback = Future<void> Function(String languageCode);
