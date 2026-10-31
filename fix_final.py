import sys

with open("lib/services/pack_downloader_service.dart", "r") as f:
    content = f.read()

# Fix 1: PathNotFoundException on delete
# Replace `if (fileExists) await file.delete();` with a safer check.
# Actually fileExists was set BEFORE the request: `bool fileExists = await file.exists();`
# But it might have been deleted by another process or earlier in the loop.
# It's safer to just do `if (await file.exists()) await file.delete();`
content = content.replace(
"""        if (downloadedBytes > 0) {
          if (previousETag == null) {
            // App was restarted, we lost the ETag, we must restart download safely
            await file.delete();""",
"""        if (downloadedBytes > 0) {
          if (previousETag == null) {
            // App was restarted, we lost the ETag, we must restart download safely
            if (await file.exists()) await file.delete();"""
)

content = content.replace(
"""        if (response.statusCode == 416) {
             await response.stream.drain();
             if (fileExists) await file.delete();""",
"""        if (response.statusCode == 416) {
             await response.stream.drain();
             if (await file.exists()) await file.delete();"""
)

content = content.replace(
"""        if (response.statusCode == 200 || (response.statusCode == 206 && previousETag != null && currentETag != previousETag)) {
            // ETag changed or server doesn't support partial content (returned 200 instead of 206)
            if (fileExists) await file.delete();""",
"""        if (response.statusCode == 200 || (response.statusCode == 206 && previousETag != null && currentETag != previousETag)) {
            // ETag changed or server doesn't support partial content (returned 200 instead of 206)
            if (await file.exists()) await file.delete();"""
)


# Fix 2: FileSystemException (OS Error: Is a directory) crashing the test.
# Even though `file.openWrite` is in a try-catch, why does it crash?
# BECAUSE `openWrite` DOES NOT THROW SYNCHRONOUSLY if it's a directory.
# It returns an `IOSink` successfully, but then it throws asynchronously on `fileSink.done` OR when you try to write to it!
# But wait, we DID add a catchError to `fileSink.done`:
"""
        // Catch disk full / file system errors
        fileSink.done.catchError((e) {
          if (!completer.isCompleted) completer.complete(false);
        });
"""
# So why is the test still crashing with an unhandled FileSystemException?
# Ah, if we write to it, `fileSink.add(chunk)` might throw? No, `IOSink.add` is synchronous and doesn't throw. The error goes to `done`.
# The stack trace says:
#   dart:io _File.openWrite
#   package:deutsch_bilarabi/services/pack_downloader_service.dart 175:27  PackDownloaderService.requestDownload
#   ...
# Wait! In Dart, some errors from `openWrite` are actually thrown asynchronously, and `fileSink.done.catchError` DOES catch them... but ONLY IF you also handle errors on the stream you passed to it? No, `openWrite` is not a `StreamConsumer`.
# To safely handle file system errors from `IOSink`, we should await `fileSink.done` inside a try-catch, OR we need to make sure we don't have unhandled errors.
# Actually, the unhandled error might come from `fileSink.add` if the sink is already closed due to an error, but it usually ignores it.
# Let's read dart:io docs: "The `done` future completes with the same error."
# Oh! The unhandled exception is crashing because we didn't put a catchError on the sink returned by `openWrite` IMMEDIATELY? We did.
# Wait, look at the stack trace:
#   dart:io _File.openWrite
#   package:deutsch_bilarabi/services/pack_downloader_service.dart 175:27 PackDownloaderService.requestDownload
# Wait! Is it throwing inside `openWrite` because the path is a directory?
# Let's try to put an explicit check `if (await FileSystemEntity.isDirectory(file.path)) throw ...` just to bypass this Dart quirk.
# Or better, let's wrap `openWrite` AND the stream listening in a broader `try`? No, the error is asynchronous.
# Let's use `Zone`? No.
# If `isDirectory(file.path)`, we can fail early:
content = content.replace(
"""        bool fileExists = await file.exists();""",
"""        bool fileExists = await file.exists();
        if (await FileSystemEntity.isDirectory(file.path)) {
            _downloadStates[languageCode] = PackDownloadState.paused;
            if (client == null) httpClient.close();
            return false;
        }"""
)


with open("lib/services/pack_downloader_service.dart", "w") as f:
    f.write(content)
