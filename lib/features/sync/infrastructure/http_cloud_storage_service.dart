import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/sync_models.dart';
import '../domain/sync_services.dart';

typedef CloudHeadersProvider = Future<Map<String, String>> Function();

final class HttpCloudStorageService implements CloudStorageService {
  HttpCloudStorageService({
    required Uri baseUri,
    required Set<String> allowedHosts,
    http.Client? client,
    CloudHeadersProvider? headersProvider,
    this.timeout = const Duration(seconds: 12),
  })  : baseUri = baseUri.path.endsWith('/')
            ? baseUri
            : baseUri.replace(path: '${baseUri.path}/'),
        allowedHosts = Set<String>.unmodifiable(
          allowedHosts.map((host) => host.trim().toLowerCase()),
        ),
        client = client ?? http.Client(),
        _headersProvider = headersProvider {
    _validateEndpoint(this.baseUri, this.allowedHosts);
    if (timeout < const Duration(seconds: 1) ||
        timeout > const Duration(seconds: 30)) {
      throw ArgumentError.value(timeout, 'timeout', 'must be 1..30 seconds');
    }
  }

  static const int maxResponseBytes = 512 * 1024;
  static const int maxRequestBytes = 256 * 1024;

  final Uri baseUri;
  final Set<String> allowedHosts;
  final http.Client client;
  final CloudHeadersProvider? _headersProvider;
  final Duration timeout;

  @override
  Future<SyncProgressSnapshot?> fetchSnapshot(String syncKey) async {
    final uri = _syncUri(syncKey);
    final request = http.Request('GET', uri)
      ..followRedirects = false
      ..headers.addAll(await _headers());
    final response = await client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(timeout);

    if (response.statusCode == 404) return null;
    _guardResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Cloud sync fetch failed.');
    }
    final decoded = _decodeMap(response.body);
    return SyncProgressSnapshot.fromJson(_map(decoded['snapshot']));
  }

  @override
  Future<CloudPushResult> pushSnapshot({
    required String syncKey,
    required SyncProgressSnapshot snapshot,
    required List<SyncQueueItem> mutations,
    String? expectedRevision,
  }) async {
    final body = jsonEncode(<String, Object?>{
      'snapshot': snapshot.toJson(),
      'mutations': mutations.map((item) => item.toJson()).toList(growable: false),
      if (expectedRevision != null) 'expectedRevision': expectedRevision,
    });
    if (utf8.encode(body).length > maxRequestBytes) {
      throw StateError('Cloud sync request exceeds the bounded payload size.');
    }

    final request = http.Request('PUT', _syncUri(syncKey))
      ..followRedirects = false
      ..headers.addAll(await _headers())
      ..headers['content-type'] = 'application/json'
      ..body = body;
    final response = await client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(timeout);

    _guardResponse(response);
    final decoded = _decodeMap(response.body);
    if (response.statusCode == 409) {
      return CloudPushResult.conflict(
        SyncProgressSnapshot.fromJson(_map(decoded['remote'])),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Cloud sync push failed.');
    }
    return CloudPushResult.applied(
      SyncProgressSnapshot.fromJson(_map(decoded['snapshot'])),
    );
  }

  Future<Map<String, String>> _headers() async {
    final provided = await _headersProvider?.call() ?? const <String, String>{};
    return <String, String>{
      'accept': 'application/json',
      for (final entry in provided.entries)
        if (_safeHeader(entry.key, entry.value)) entry.key: entry.value,
    };
  }

  Uri _syncUri(String syncKey) {
    final normalized = syncKey.trim();
    if (normalized.isEmpty || normalized.length > 160) {
      throw ArgumentError.value(syncKey, 'syncKey', 'invalid sync key');
    }
    return baseUri.resolve(
      'v1/sync/${Uri.encodeComponent(normalized)}',
    );
  }

  static void _validateEndpoint(Uri uri, Set<String> allowedHosts) {
    if (uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      throw ArgumentError('Cloud sync endpoint must be a clean HTTPS URI.');
    }
    if (allowedHosts.isEmpty ||
        !allowedHosts.contains(uri.host.toLowerCase())) {
      throw ArgumentError('Cloud sync endpoint host must be allowlisted.');
    }
  }

  static void _guardResponse(http.Response response) {
    if (response.statusCode >= 300 && response.statusCode < 400) {
      throw StateError('Cloud sync redirects are blocked.');
    }
    if (response.bodyBytes.length > maxResponseBytes) {
      throw StateError('Cloud sync response exceeds the bounded size.');
    }
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (response.bodyBytes.isNotEmpty &&
        !contentType.startsWith('application/json')) {
      throw StateError('Cloud sync response must be JSON.');
    }
  }

  static Map<String, Object?> _decodeMap(String body) {
    if (body.trim().isEmpty) return const <String, Object?>{};
    final decoded = jsonDecode(body);
    return _map(decoded);
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is! Map) throw const FormatException('expected JSON object');
    return <String, Object?>{
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: entry.value,
    };
  }

  static bool _safeHeader(String name, String value) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty ||
        normalized == 'host' ||
        normalized == 'content-length' ||
        value.contains('\n') ||
        value.contains('\r')) {
      return false;
    }
    return true;
  }

  void close() => client.close();
}
