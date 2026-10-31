import sys

with open("test/jules/J015/pack_downloader_test.dart", "r") as f:
    content = f.read()

# Add missing tests for application restart and insufficient disk.
new_tests = """
    test('Restarting application discards unverified partial files to prevent corruption', () async {
      int requestCount = 0;
      final file = File('./pack_tr-TR.tmp');
      await file.writeAsBytes([1, 2]); // Simulate left-over file from previous app run

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      final client = MockClient((request) async {
        requestCount++;
        // It should NOT ask for a range since memory ETag is lost on app restart
        expect(request.headers.containsKey('Range'), false);

        return http.Response.bytes(
          [1, 2, 3, 4],
          200,
          headers: {'etag': '12345'},
        );
      });

      // No memory state exists yet for tr-TR since app restarted
      final success = await PackDownloaderService.requestDownload(
        'tr-TR',
        'http://example.com/pack7.zip',
        expectedHash,
        client: client
      );

      expect(success, true);
      expect(requestCount, 1);
      final finalBytes = await file.readAsBytes();
      expect(finalBytes, [1, 2, 3, 4]); // File was correctly overwritten from scratch
    });

    test('Insufficient disk space fails gracefully without crashing', () async {
      // Simulate by creating a directory where a file should be, causing openWrite to throw FileSystemException asynchronously on sink.done
      // Actually we can't easily mock IOSink failure in Dart without a custom mock file system.
      // We will simulate it by closing the sink manually during the stream, which causes write error.
      // Or we can mock the HTTP client to yield large amounts of data, but that's memory intensive.
      // Wait, we can test that the catchError on done actually prevents unhandled exceptions.
      // A better way is to make the temporary path inaccessible or read-only, but path_provider mock returns '.', which is writable.
      // Let's create a file that's locked or read only if possible. But in Dart test environment, this is hard.
      // We'll skip complex disk mocking and test it implicitly by ensuring the code paths are solid.
      // Let's manually trigger a file system error by making the path a directory instead of a file.

      final file = File('./pack_it-IT.tmp');
      if (await file.exists()) {
          await file.delete();
      }

      // Create a directory with the same name. This will cause File.openWrite to fail.
      final dir = Directory('./pack_it-IT.tmp');
      await dir.create();

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      final client = MockClient((request) async {
        return http.Response.bytes(
          [1, 2, 3, 4],
          200,
        );
      });

      final success = await PackDownloaderService.requestDownload(
        'it-IT',
        'http://example.com/pack8.zip',
        expectedHash,
        client: client
      );

      // Should return false cleanly and not crash the test with unhandled exception
      expect(success, false);
      expect(PackDownloaderService.getDownloadState('it-IT'), PackDownloadState.paused);

      await dir.delete();
    });
  });
}
"""

content = content.replace("  });\n}\n", new_tests)

with open("test/jules/J015/pack_downloader_test.dart", "w") as f:
    f.write(content)
