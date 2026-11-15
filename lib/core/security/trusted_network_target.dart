import 'dart:io';

/// Thrown when a network target is outside the shipped trust policy.
class UntrustedNetworkTargetException implements Exception {
  final String reason;
  final String target;

  const UntrustedNetworkTargetException(this.target, this.reason);

  @override
  String toString() => 'UntrustedNetworkTargetException: $reason ($target)';
}

/// Single authority for "may this process talk to this URL?".
///
/// The application ships with the INTERNET permission removed from the merged
/// manifest, so runtime network calls are optional at most. Whenever a build
/// does enable a transport, the target still has to satisfy this policy:
/// HTTPS only, no embedded credentials, standard TLS port, a public DNS host,
/// and — when the caller knows the canonical origins — membership in that list.
class TrustedNetworkTarget {
  static const Set<int> _allowedPorts = {443};
  static const String _dnsHostPattern =
      r'^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$';
  static const List<String> _blockedSuffixes = [
    '.local',
    '.localhost',
    '.internal',
    '.intranet',
    '.home.arpa',
    '.lan',
    '.test',
    '.invalid',
    '.example',
  ];
  static final RegExp _dnsHost = RegExp(_dnsHostPattern);

  /// Returns the validated URI or throws a typed, non-secret-bearing error.
  static Uri requireTrusted(
    Uri uri, {
    Set<String>? allowedHosts,
    bool allowNonDefaultPort = false,
  }) {
    final target = uri.hasAuthority ? '${uri.scheme}://${uri.host}' : uri.toString();

    if (uri.scheme.toLowerCase() != 'https') {
      throw UntrustedNetworkTargetException(target, 'only https targets are permitted');
    }
    if (uri.userInfo.isNotEmpty) {
      throw UntrustedNetworkTargetException(target, 'URL credentials are not permitted');
    }
    final host = uri.host.toLowerCase();
    if (host.isEmpty) {
      throw UntrustedNetworkTargetException(target, 'target has no host');
    }
    if (uri.hasPort && !(_allowedPorts.contains(uri.port) || allowNonDefaultPort)) {
      throw UntrustedNetworkTargetException(target, 'non-standard port ${uri.port} is not permitted');
    }
    if (_isIpLiteral(host)) {
      throw UntrustedNetworkTargetException(
        target,
        'IP literals (including loopback, private, link-local and ULA ranges) are not permitted',
      );
    }
    if (host == 'localhost' || host.endsWith('.localhost')) {
      throw UntrustedNetworkTargetException(target, 'loopback hosts are not permitted');
    }
    for (final suffix in _blockedSuffixes) {
      if (host.endsWith(suffix)) {
        throw UntrustedNetworkTargetException(target, 'reserved host suffix $suffix is not permitted');
      }
    }
    if (!_dnsHost.hasMatch(host)) {
      throw UntrustedNetworkTargetException(target, 'host is not a public DNS name');
    }
    if (allowedHosts != null && allowedHosts.isNotEmpty) {
      final normalized = allowedHosts.map((entry) => entry.toLowerCase()).toSet();
      if (!normalized.contains(host)) {
        throw UntrustedNetworkTargetException(target, 'host is outside the configured allowlist');
      }
    }
    return uri;
  }

  /// Convenience wrapper that returns false instead of throwing.
  static bool isTrusted(Uri uri, {Set<String>? allowedHosts}) {
    try {
      requireTrusted(uri, allowedHosts: allowedHosts);
      return true;
    } on UntrustedNetworkTargetException {
      return false;
    }
  }

  /// Rejects IPv4/IPv6 literals in every textual form, including the
  /// integer/octal/hex encodings that bypass naive dotted-quad checks.
  static bool _isIpLiteral(String host) {
    if (host.contains(':')) return true;
    if (InternetAddress.tryParse(host) != null) return true;
    if (!RegExp(r'^[0-9.]+$').hasMatch(host)) return false;
    final parts = host.split('.').where((part) => part.isNotEmpty).toList();
    if (parts.length == 4 && parts.every((part) => int.tryParse(part) != null)) {
      return true;
    }
    // A single decimal/octal/hex integer is a valid IPv4 literal.
    return parts.length == 1 && int.tryParse(parts.first) != null;
  }
}
