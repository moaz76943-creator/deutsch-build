import '../models/backend_runtime_config.dart';
import 'backend_http_transport.dart';
import 'backend_transport.dart';

/// Composes the authentication backend transport from non-secret runtime configuration.
final class BackendTransportFactory {
  const BackendTransportFactory._();

  static BackendTransport fromRuntimeConfig(BackendRuntimeConfig config) {
    if (!config.isConfigured) {
      return const UnavailableBackendTransport();
    }
    return HttpBackendTransport(config.baseUri!);
  }
}
