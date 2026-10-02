import 'package:deutsch_bilarabi/features/audio/data/audio_manifest_catalog.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manifest resolves only explicit safe recorded audio paths', () {
    final catalog = AudioManifestCatalog.parse(
      '{"version":1,"entries":['
      '{"contentId":"de-1","word":"de-1.mp3","sentence":"sent/de-1.ogg"}'
      ']}',
    );

    expect(
      catalog.recordedAssetFor(
        conceptId: 'de-1',
        variant: AudioVariant.word,
      ),
      'content/german/audio/de-1.mp3',
    );
    expect(
      catalog.recordedAssetFor(
        conceptId: 'de-1',
        variant: AudioVariant.pronunciation,
      ),
      isNull,
    );
  });

  test('manifest rejects traversal and unsupported extensions', () {
    expect(
      () => AudioManifestCatalog.parse(
        '{"version":1,"entries":['
        '{"contentId":"de-1","word":"../secret.mp3"}'
        ']}',
      ),
      throwsFormatException,
    );
    expect(
      () => AudioManifestCatalog.parse(
        '{"version":1,"entries":['
        '{"contentId":"de-1","word":"script.js"}'
        ']}',
      ),
      throwsFormatException,
    );
  });
}
