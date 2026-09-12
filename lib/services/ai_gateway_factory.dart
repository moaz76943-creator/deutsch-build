import '../models/ai_runtime_config.dart';
import 'ai_gateway.dart';

/// Composition-root factory for the optional cloud AI adapter.
final class AiGatewayFactory {
  const AiGatewayFactory._();

  static AiGateway fromRuntimeConfig(AiRuntimeConfig config) {
    if (!config.isConfigured) return const OfflineAiGateway();
    return HttpsAiGateway(
      baseUri: config.baseUri!,
      allowedHostsCsv: config.allowedHosts.join(','),
    );
  }
}
