import sys

with open("lib/services/pack_downloader_service.dart", "r") as f:
    content = f.read()

# Fix the ETag restart logic which seems to be returning false in requestDownload.
# Ah, if downloadedBytes is > 0, we do:
"""
        if (downloadedBytes > 0) {
          if (previousETag == null) {
            // App was restarted, we lost the ETag, we must restart download safely
            await file.delete();
            downloadedBytes = 0;
          } else {
"""
# And then we do:
"""
        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll(headers);
"""
# BUT! If we deleted the file, the file no longer exists, but we are about to `openWrite` it.
# openWrite is perfectly fine creating a new file if it doesn't exist.
# However, if it throws FileSystemException synchronously, the try-catch block catches it:
"""
        late IOSink fileSink;
        try {
          fileSink = file.openWrite(mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);
        } catch (e) {
          _downloadStates[languageCode] = PackDownloadState.paused;
          if (client == null) httpClient.close();
          return false;
        }
"""
# Why is openWrite throwing "Is a directory" in the test?
# Because in the test we DO:
# `final dir = Directory('./pack_it-IT.tmp'); await dir.create();`
# And then we do `file.openWrite`. It throws synchronously.
# BUT if it throws synchronously, the `try-catch` should return false!
# Wait, why does the test timeout instead of completing?
# Because `PackDownloaderService.requestDownload` returns `false` correctly!
# BUT the test has a `client` that returns a `StreamedResponse`. The MockClient stream might not be consumed?
# Actually, we didn't drain the response in the openWrite catch block!
# If openWrite fails, we MUST close/drain the response stream! Otherwise it hangs in MockClient if the stream isn't closed.

content = content.replace(
"""        late IOSink fileSink;
        try {
          fileSink = file.openWrite(mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);
        } catch (e) {
          _downloadStates[languageCode] = PackDownloadState.paused;
          if (client == null) httpClient.close();
          return false;
        }""",
"""        late IOSink fileSink;
        try {
          fileSink = file.openWrite(mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);
        } catch (e) {
          await response.stream.drain();
          _downloadStates[languageCode] = PackDownloadState.paused;
          if (client == null) httpClient.close();
          return false;
        }"""
)

# And why do ETag and AppRestart tests fail?
# They return false. Let's see why:
# `previousETag == null` -> `await file.delete()`.
# Then `response.statusCode` is 200.
# Then `downloadedBytes` is 0, so it opens file in write mode.
# It writes [1, 2, 3, 4] and Completes true.
# Then `success == true`, it breaks the while loop.
# Then `final isValid = await PackAdmissionService.verifyAndAdmitPack(file, expectedHash);`
# `expectedHash` is `9f64a...`.
# Wait, maybe `file.delete()` removes it, then `openWrite` writes to it, but `getApplicationSupportDirectory()` gives a DIFFERENT path than the test's `File('./pack_es-ES.tmp')`?
# YES!
# In the test, we create `File('./pack_es-ES.tmp')`.
# But in `requestDownload`, we use:
# `final dir = await getApplicationSupportDirectory();`
# `final file = File('${dir.path}/pack_${languageCode}.tmp');`
# In the test `path_provider` mock, we set `return '.'` for `getApplicationSupportPath`.
# So `dir.path` is `.`.
# So `file` is `./pack_es-ES.tmp`.
# So the paths match.
# Then why does it fail? Let's add debug prints.

with open("lib/services/pack_downloader_service.dart", "w") as f:
    f.write(content)
