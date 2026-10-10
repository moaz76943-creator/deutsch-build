/// Non-secret runtime configuration for the authentication backend.
///
/// Values come from Dart compile-time defines. Missing or invalid configuration
/// is represented as an unconfigured state so boot can fail closed.
final class BackendRuntimeConfig {
  const BackendRuntimeConfig._({
    required this.baseUri,
    required this.allowedHosts,
    required this.allowedHostsValid,
  });

  static const String baseUrlDefine = 'DEUTSCH_AUTH_BASE_URL';
  static const String allowedHostsDefine = 'DEUTSCH_AUTH_ALLOWED_HOSTS';
  static const int maxHostEntries = 32;
  static const int maxHostLength = 253;

  final Uri? baseUri;
  final Set<String> allowedHosts;
  final bool allowedHostsValid;

  bool get isConfigured {
    if (!allowedHostsValid) return false;
    return baseUri != null &&
        (allowedHosts.isEmpty ||
            allowedHosts.contains(baseUri!.host.toLowerCase()));
  }

  static BackendRuntimeConfig fromEnvironment() {
    const rawBaseUrl = String.fromEnvironment(baseUrlDefine, defaultValue: '');
    const rawAllowedHosts = String.fromEnvironment(
      allowedHostsDefine,
      defaultValue: '',
    );

    final baseUri = _parseBaseUri(rawBaseUrl);
    final parsedAllowedHosts = _parseAllowedHosts(rawAllowedHosts);
    return BackendRuntimeConfig._(
      baseUri: baseUri,
      allowedHosts: parsedAllowedHosts.hosts,
      allowedHostsValid: parsedAllowedHosts.valid,
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
    if (uri.userInfo.isNotEmpty) return null;
    if (uri.query.isNotEmpty || uri.fragment.isNotEmpty) return null;
    if (uri.host.length > maxHostLength) return null;

    return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  }

  static ({Set<String> hosts, bool valid}) _parseAllowedHosts(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return (hosts: const <String>{}, valid: true);
    }

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
