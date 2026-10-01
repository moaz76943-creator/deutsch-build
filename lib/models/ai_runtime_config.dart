/// Non-secret compile-time configuration for the optional cloud AI adapter.
///
/// The UI must never read compile-time defines directly. Missing or invalid
/// values produce an unconfigured state so the composition root can fail
/// closed to the offline gateway.
final class AiRuntimeConfig {
  const AiRuntimeConfig._({
    required this.baseUri,
    required this.allowedHosts,
    required this.allowedHostsValid,
  });

  static const String baseUrlDefine = 'DEUTSCH_AI_BASE_URL';
  static const String allowedHostsDefine = 'DEUTSCH_AI_ALLOWED_HOSTS';
  static const int maxHostEntries = 32;
  static const int maxHostLength = 253;

  final Uri? baseUri;
  final Set<String> allowedHosts;
  final bool allowedHostsValid;

  bool get isConfigured =>
      allowedHostsValid &&
      baseUri != null &&
      allowedHosts.contains(baseUri!.host.toLowerCase());

  static AiRuntimeConfig fromEnvironment() {
    const rawBaseUrl = String.fromEnvironment(baseUrlDefine, defaultValue: '');
    const rawAllowedHosts = String.fromEnvironment(
      allowedHostsDefine,
      defaultValue: '',
    );
    final baseUri = _parseBaseUri(rawBaseUrl);
    final parsed = _parseAllowedHosts(rawAllowedHosts);
    return AiRuntimeConfig._(
      baseUri: baseUri,
      allowedHosts: parsed.hosts,
      allowedHostsValid: parsed.valid,
    );
  }

  static Uri? _parseBaseUri(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    late final Uri uri;
    try {
      uri = Uri.parse(value);
    } on FormatException {
      return null;
    }
    if (uri.scheme.toLowerCase() != 'https' || uri.host.isEmpty) return null;
    if (uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      return null;
    }
    if (uri.host.length > maxHostLength) return null;
    return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  }

  static ({Set<String> hosts, bool valid}) _parseAllowedHosts(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return (hosts: const <String>{}, valid: false);
    final rawParts = value.split(',');
    final parts = rawParts.map((host) => host.trim().toLowerCase()).toSet();
    if (rawParts.length > maxHostEntries ||
        parts.any((host) => host.isEmpty || host.length > maxHostLength) ||
        parts.any((host) => Uri(scheme: 'https', host: host).host != host)) {
      return (hosts: const <String>{}, valid: false);
    }
    return (hosts: Set.unmodifiable(parts), valid: true);
  }
}
