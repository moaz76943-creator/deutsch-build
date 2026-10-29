import 'dart:convert';

import 'package:http/http.dart' as http;

class AiReview {
  final String corrected;
  final List<String> issues;
  final String explanation;
  const AiReview({
    required this.corrected,
    required this.issues,
    required this.explanation,
  });
}

abstract class AiGateway {
  bool get enabled;
  Future<AiReview> reviewWriting(String text, {String level = 'A1'});
  Future<String> continueConversation({
    required String scenario,
    required String message,
    String level = 'A1',
  });
}

class OfflineAiGateway implements AiGateway {
  const OfflineAiGateway();
  @override
  bool get enabled => false;
  @override
  Future<AiReview> reviewWriting(String text, {String level = 'A1'}) async =>
      const AiReview(
        corrected: '',
        issues: ['المراجعة السحابية غير مفعّلة؛ استخدم الفحص المحلي.'],
        explanation: 'لا يتم إرسال النص إلى أي خادم.',
      );
  @override
  Future<String> continueConversation({
    required String scenario,
    required String message,
    String level = 'A1',
  }) async =>
      'الوضع المحلي: أكمل الحوار باستخدام العبارات المقترحة داخل التطبيق.';
}

/// Optional remote adapter. It requires an HTTPS endpoint supplied by the app owner.
/// No API key is embedded in the APK and no endpoint is enabled by default.
class HttpsAiGateway implements AiGateway {
  final Uri baseUri;
  final http.Client client;
  final Duration timeout;
  final Set<String> allowedHosts;
  static const maxResponseBytes = 512 * 1024;
  static const minRequestInterval = Duration(milliseconds: 750);
  Future<void> _requestTail = Future<void>.value();
  DateTime? _lastRequestAt;
  HttpsAiGateway({
    required Uri baseUri,
    required String allowedHostsCsv,
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  })  : baseUri = baseUri.path.endsWith('/')
            ? baseUri
            : baseUri.replace(path: '${baseUri.path}/'),
        allowedHosts = allowedHostsCsv
            .split(',')
            .map((host) => host.trim().toLowerCase())
            .where((host) => host.isNotEmpty)
            .toSet(),
        client = client ?? http.Client() {
    if (baseUri.scheme != 'https')
      throw ArgumentError('AI endpoint must use HTTPS.');
    if (baseUri.host.isEmpty)
      throw ArgumentError('AI endpoint must include a host.');
    if (baseUri.userInfo.isNotEmpty)
      throw ArgumentError('AI endpoint must not include credentials.');
    if (baseUri.query.isNotEmpty || baseUri.fragment.isNotEmpty)
      throw ArgumentError(
        'AI endpoint must not include query or fragment data.',
      );
    if (baseUri.host.length > 253)
      throw ArgumentError('AI endpoint host is too long.');
    if (allowedHosts.isEmpty)
      throw ArgumentError('Cloud AI host allowlist is required.');
    if (!allowedHosts.contains(baseUri.host.toLowerCase())) {
      throw ArgumentError(
        'Allowed AI endpoint host does not match configured endpoint.',
      );
    }
  }
  @override
  bool get enabled => true;

  Future<void> _paceRequests() {
    _requestTail = _requestTail.then((_) async {
      final now = DateTime.now();
      final last = _lastRequestAt;
      if (last != null) {
        final elapsed = now.difference(last);
        final remaining = minRequestInterval - elapsed;
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      }
      _lastRequestAt = DateTime.now();
    });
    return _requestTail;
  }

  static final RegExp _sensitivePayload = RegExp(
    r'(?:\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b)|'
    r'(?:\b(?:\+?\d[\d .()\-]{7,}\d)\b)|'
    r'(?:\b(?:api[_-]?key|access[_-]?token|refresh[_-]?token|authorization|bearer)\b\s*[:=]\s*\S+)|'
    r'(?:\b\d[\d -]{11,18}\d\b)',
    caseSensitive: false,
  );

  static void _guardOutgoingText(String value) {
    if (_sensitivePayload.hasMatch(value)) {
      throw StateError(
        'Potentially sensitive data blocked before cloud AI transmission.',
      );
    }
  }

  Future<AiReview> reviewWriting(String text, {String level = 'A1'}) async {
    _guardOutgoingText(text);
    await _paceRequests();
    final body = jsonEncode({
      'task': 'writing_review',
      'level': level,
      'text': text.trim().substring(
            0,
            text.trim().length.clamp(0, 2000).toInt(),
          ),
    });
    final request = http.Request('POST', baseUri.resolve('v1/review'))
      ..followRedirects = false
      ..headers['content-type'] = 'application/json'
      ..body = body;
    final response = await client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(timeout);
    if (response.statusCode >= 300 && response.statusCode < 400)
      throw StateError('AI endpoint redirects are blocked.');
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw StateError('AI review request failed.');
    _guardResponse(response);
    final json = jsonDecode(response.body);
    if (json is! Map) throw StateError('Invalid AI response.');
    return AiReview(
      corrected: (json['corrected'] ?? '').toString().substring(
            0,
            (json['corrected'] ?? '').toString().length.clamp(0, 2000).toInt(),
          ),
      issues: (json['issues'] is List
          ? (json['issues'] as List).whereType<String>().take(8).toList()
          : const <String>[]),
      explanation: (json['explanation'] ?? '').toString().substring(
            0,
            (json['explanation'] ?? '')
                .toString()
                .length
                .clamp(0, 3000)
                .toInt(),
          ),
    );
  }

  @override
  Future<String> continueConversation({
    required String scenario,
    required String message,
    String level = 'A1',
  }) async {
    _guardOutgoingText(scenario);
    _guardOutgoingText(message);
    await _paceRequests();
    final body = jsonEncode({
      'task': 'conversation',
      'level': level,
      'scenario': scenario.substring(0, scenario.length.clamp(0, 160).toInt()),
      'message': message.trim().substring(
            0,
            message.trim().length.clamp(0, 2000).toInt(),
          ),
    });
    final request = http.Request('POST', baseUri.resolve('v1/conversation'))
      ..followRedirects = false
      ..headers['content-type'] = 'application/json'
      ..body = body;
    final response = await client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(timeout);
    if (response.statusCode >= 300 && response.statusCode < 400)
      throw StateError('AI endpoint redirects are blocked.');
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw StateError('Conversation request failed.');
    _guardResponse(response);
    final json = jsonDecode(response.body);
    if (json is! Map) throw StateError('Invalid AI response.');
    return (json['reply'] ?? '').toString().substring(
          0,
          (json['reply'] ?? '').toString().length.clamp(0, 3000).toInt(),
        );
  }

  static void _guardResponse(http.Response response) {
    if (response.bodyBytes.length > maxResponseBytes)
      throw StateError('AI response is too large.');
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (!contentType.startsWith('application/json'))
      throw StateError('AI response must be JSON.');
  }

  void close() => client.close();
}
