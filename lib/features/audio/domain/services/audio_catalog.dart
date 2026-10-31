import '../entities/audio_request.dart';

abstract interface class AudioCatalog {
  String? recordedAssetFor({
    required String conceptId,
    required AudioVariant variant,
  });
}

final class EmptyAudioCatalog implements AudioCatalog {
  const EmptyAudioCatalog();

  @override
  String? recordedAssetFor({
    required String conceptId,
    required AudioVariant variant,
  }) =>
      null;
}
