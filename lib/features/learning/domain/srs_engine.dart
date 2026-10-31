/// Canonical pure-Dart SRS surface for the learning feature domain.
///
/// The implementation remains single-sourced in lib/core/srs/** to avoid a
/// parallel scheduling engine. Feature code imports this domain entrypoint while
/// legacy callers may continue importing the established core path.
export '../../../core/srs/srs_engine.dart';
export '../../../core/srs/srs_models.dart';
