with open("lib/services/pack_downloader_service.dart", "r") as f:
    content = f.read()

# Fix 1: Properly clean up StreamedResponse on errors and 416s (socket leak)
# In dart http package, we have to drain the stream if we don't want to consume it, or use response.stream.drain()
# actually since it's an http.Response from http.send, wait, the method uses `await httpClient.send(request)`. That returns http.StreamedResponse.
# If we don't listen to it, we should do await response.stream.drain() to release the connection or call request's close logic.
# A simpler approach is to call `await response.stream.drain();` before `continue;` or returning.
content = content.replace(
"""        if (response.statusCode == 416) {
             // Range not satisfiable, might be already downloaded or file is bigger
             if (fileExists) await file.delete();
             downloadedBytes = 0;
             retries = 0; // Reset retries since it's a valid response, just bad state
             continue;
        }""",
"""        if (response.statusCode == 416) {
             await response.stream.drain();
             if (fileExists) await file.delete();
             downloadedBytes = 0;
             retries = 0;
             continue;
        }"""
)

content = content.replace(
"""        if (response.statusCode >= 400) {
           retries++;
           if (retries > maxRetries) {
             _downloadStates[languageCode] = PackDownloadState.rejected;
             if (client == null) httpClient.close();
             return false;
           }
           await Future.delayed(Duration(seconds: retries));
           continue;
        }""",
"""        if (response.statusCode >= 400) {
           await response.stream.drain();
           retries++;
           if (retries > maxRetries) {
             _downloadStates[languageCode] = PackDownloadState.rejected;
             if (client == null) httpClient.close();
             return false;
           }
           await Future.delayed(Duration(seconds: retries));
           continue;
        }"""
)

# Fix 2: Unsafe Resume on Restart.
# The server requires an `If-Range` header if we want to safely resume without knowing the previous ETag in memory.
# Or if we don't know the ETag, we should NOT send `Range` header and just download from scratch to be safe on restart.
# Let's read the ETag from memory, if it's null and we have partial bytes, we shouldn't attempt resume, we should restart.
# Alternatively we can just delete the file if _eTags[languageCode] == null.

content = content.replace(
"""        final headers = <String, String>{};
        if (downloadedBytes > 0) {
          headers['Range'] = 'bytes=${downloadedBytes}-';
        }""",
"""        final headers = <String, String>{};
        final previousETag = _eTags[languageCode];

        if (downloadedBytes > 0) {
          if (previousETag == null) {
            // App was restarted, we lost the ETag, we must restart download safely
            await file.delete();
            downloadedBytes = 0;
          } else {
            headers['Range'] = 'bytes=${downloadedBytes}-';
            headers['If-Range'] = previousETag;
          }
        }"""
)


# Fix 3: Handle fileSink.done error for disk full
content = content.replace(
"""        final completer = Completer<bool>();
        _activeCompleters[languageCode] = completer;

        _activeSubscriptions[languageCode] = response.stream.listen(""",
"""        final completer = Completer<bool>();
        _activeCompleters[languageCode] = completer;

        // Catch disk full / file system errors
        fileSink.done.catchError((e) {
          if (!completer.isCompleted) completer.complete(false);
        });

        _activeSubscriptions[languageCode] = response.stream.listen("""
)

with open("lib/services/pack_downloader_service.dart", "w") as f:
    f.write(content)
