// Language Intelligence Contract - Post-V1 Expansion
// Encapsulates language-specific capabilities (morphology, normalization, grammar) behind a unified boundary

enum CapabilityStatus { supported, limited, unsupported }

abstract class LanguageIntelligenceContract {
  String get languageCode;
  CapabilityStatus getCapability(String capabilityName);
  String normalizeText(String input);
}

class BaseLanguageIntelligence implements LanguageIntelligenceContract {
  @override
  final String languageCode;
  final Map<String, CapabilityStatus> capabilities;

  BaseLanguageIntelligence({
    required this.languageCode,
    this.capabilities = const {},
  });

  @override
  CapabilityStatus getCapability(String capabilityName) {
    return capabilities[capabilityName] ?? CapabilityStatus.unsupported;
  }

  @override
  String normalizeText(String input) {
    return input.trim();
  }
}
