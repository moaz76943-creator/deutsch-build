1. **Model requested, downloading, paused, validating, installed, cancelled, and rejected states.**
    - Define an enum `DownloadState` with these states in `pack_downloader_service.dart`.
    - Expose the current state and progress via `Stream` or `ValueNotifier`. Let's use `Stream<DownloadState>` or `Stream<PackDownloadProgress>` in `PackDownloaderService`.
2. **Require explicit user intent before optional acquisition.**
    - `downloadPack` requires user intervention.
3. **Implement safe resumable transfers when server identity and transfer capabilities allow them.**
    - Use `http` package, check `Accept-Ranges: bytes`.
    - If `ETag` changes or `Accept-Ranges` is missing, start over.
    - Save partial downloads with `.part` extension in the temporary directory.
4. **Bound retries, network usage and temporary disk consumption.**
    - Limited retries (e.g. 3 times).
    - Avoid huge infinite loops.
    - Clean up `.part` file if we get a totally new `ETag` or after rejection.
5. **Reject mismatched hashes and incomplete packages.**
    - Verify with `PackAdmissionService.verifyAndAdmitPack`.
6. **Pass content to the existing pack admission authority; never activate unverified downloaded bytes.**
    - After download is 100%, call `PackAdmissionService.verifyAndAdmitPack(downloadedFile, expectedHash)`.
    - If it fails, delete the file, move to `rejected` state.
7. **Preserve installed content during network failures.**
    - The actual atomic swap happens in `PackAdmissionService` or beyond. Our downloader only works on temporary `.part` and staging files, so it inherently won't break installed ones.
8. **Prevent duplicate concurrent downloads of the same pack.**
    - Keep a map of active downloads `Map<String, Future<void>>` or similar. If one is active, don't start another.
9. **Test failed connections, changed ETags, cancellation, insufficient disk and application restart.**
    - We will mock the `http.Client` for testing.
10. **Keep cloud-only services and additional paid APIs absent.**
    - Pure Dart/Flutter `http` package and standard IO.
