import sys

with open("lib/services/pack_downloader_service.dart", "r") as f:
    content = f.read()

# Fix 1: openWrite failing synchronously needs to be caught in try-catch block inside while loop,
# or just wrapping the while loop. Currently the try-catch wraps the while loop but returns false, which is correct,
# but the exception in openWrite throws synchronously in the try block and gets caught by the outer try-catch!
# Wait, if it throws synchronously and caught by outer try-catch, it sets _downloadStates to paused and returns false.
# But the test says:
#   FileSystemException: Cannot open file, path = './pack_it-IT.tmp' (OS Error: Is a directory, errno = 21)
#   dart:io _File.openWrite
# If it's caught by outer try-catch, why is the test failing with FileSystemException?
# Ah, the test itself timed out because the exception crashed the zone, or wait, no, `test` runner considers any unhandled error as failure.
# Wait, `file.openWrite()` doesn't throw a synchronous exception. It returns an `IOSink` immediately.
# The `FileSystemException` is thrown asynchronously when the first chunk is written, OR it throws on `fileSink.done`.
# Let's see the stack trace:
#   dart:io _File.openWrite
#   package:deutsch_bilarabi/services/pack_downloader_service.dart 173:31
# This implies openWrite DOES throw synchronously? No, `_File.openWrite` in dart:io might throw synchronously if it can immediately detect it.
# If it throws synchronously, the outer `try {` block catches it.
# Let's wrap file.openWrite in a try/catch.

content = content.replace(
"""        final fileSink = file.openWrite(mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);
        _activeSinks[languageCode] = fileSink;

        final completer = Completer<bool>();
        _activeCompleters[languageCode] = completer;

        // Catch disk full / file system errors
        fileSink.done.catchError((e) {
          if (!completer.isCompleted) completer.complete(false);
        });""",
"""        late IOSink fileSink;
        try {
          fileSink = file.openWrite(mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);
        } catch (e) {
          _downloadStates[languageCode] = PackDownloadState.paused;
          if (client == null) httpClient.close();
          return false;
        }

        _activeSinks[languageCode] = fileSink;

        final completer = Completer<bool>();
        _activeCompleters[languageCode] = completer;

        // Catch disk full / file system errors
        fileSink.done.catchError((e) {
          if (!completer.isCompleted) completer.complete(false);
        });"""
)

# Fix 2: "Resumable transfer with ETag change forces restart" returned false instead of true.
# In test `request.headers.containsKey('Range')` was called... wait.
# Oh, in the ETag change test, we respond with 200 OK.
# In pack_downloader_service:
"""
        if (response.statusCode == 200 || (response.statusCode == 206 && previousETag != null && currentETag != previousETag)) {
            // ETag changed or server doesn't support partial content (returned 200 instead of 206)
            if (fileExists) await file.delete();
            downloadedBytes = 0;
            _eTags[languageCode] = currentETag ?? '';
"""
# And then we write. What fails? Let's check `downloadedBytes > 0 ? FileMode.append : FileMode.write`. Since downloadedBytes = 0, we use write.
# Why does it return false? It might fail admission?
# The expected hash is 9f64a... (for [1,2,3,4]). The test returns [1,2,3,4]. So admission should pass.
# Maybe `file.delete()` fails because the file doesn't exist? `if (fileExists) await file.delete();` should be fine.
# Let's check `retries`. Maybe it hits a retry loop?
# Wait! In the restart fix, I added:
"""
        if (downloadedBytes > 0) {
          if (previousETag == null) {
            // App was restarted, we lost the ETag, we must restart download safely
            await file.delete();
            downloadedBytes = 0;
"""
# BUT `previousETag` is null in the test because we just did `await file.writeAsBytes([1, 2]);` without setting `_eTags`.
# So `previousETag` is null. It deletes the file and sets `downloadedBytes = 0`.
# THEN it goes down and creates a request WITHOUT Range header!
# But the MockClient expects a Range header:
# `expect(range, 'bytes=2-');`
# Oh! The test EXPECTS it to ask for bytes=2-, but because I made it safe on restart, it doesn't ask for a range!
# Let's update the test to match the new safe behavior. The test `Resumable transfer with ETag change forces restart` shouldn't expect `bytes=2-` anymore if the app restarted.
# Actually, the test was testing that IF it resumes, and the ETag changes. To simulate an ETag change during resume, we need `_eTags[languageCode]` to be set.
# Let's just update the test to set `_eTags['es-ES'] = 'old_etag'` BEFORE starting the download! We can't access `_eTags` directly, but we can do a dummy download first.
pass

with open("lib/services/pack_downloader_service.dart", "w") as f:
    f.write(content)
