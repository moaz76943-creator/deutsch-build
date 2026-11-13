import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';

void main() {
  group('PackDownloaderService - High-Risk Security & Input Validation', () {
    test('rejects invalid language codes to prevent path injection', () {
      expect(
        () => PackDownloaderService.requestDownload(
          '../evil',
          'http://example.com/pack.zip',
          'deadbeef',
        ),
        throwsArgumentError,
      );
      expect(
        () => PackDownloaderService.requestDownload(
          'de;rm -rf',
          'http://example.com/pack.zip',
          'deadbeef',
        ),
        throwsArgumentError,
      );
    });

    test('legacy downloadPack never fabricates success', () async {
      final result = await PackDownloaderService.downloadPack('de');
      expect(result, isFalse);
    });

    test('isPackDownloaded returns false for invalid codes', () async {
      expect(await PackDownloaderService.isPackDownloaded('invalid!!'), isFalse);
      expect(await PackDownloaderService.isPackDownloaded(''), isFalse);
    });

    test('cancelDownload on non-existent is safe', () async {
      await PackDownloaderService.cancelDownload('nonexistent-lang');
      expect(PackDownloaderService.getDownloadState('nonexistent-lang'), PackDownloadState.cancelled);
    });
  });
}
