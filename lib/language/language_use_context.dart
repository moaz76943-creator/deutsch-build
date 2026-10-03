import 'language_role.dart';

/// Explicit active USER / SOURCE / TARGET language selection.
///
/// This value does not resolve registry membership and does not infer one role
/// from another. USER == SOURCE is valid and requires no special case.
final class LanguageUseContext {
  final String userLanguageId;
  final String sourceLanguageId;
  final String targetLanguageId;

  LanguageUseContext({
    required this.userLanguageId,
    required this.sourceLanguageId,
    required this.targetLanguageId,
  }) {
    _requireNonEmpty(userLanguageId, 'userLanguageId');
    _requireNonEmpty(sourceLanguageId, 'sourceLanguageId');
    _requireNonEmpty(targetLanguageId, 'targetLanguageId');
  }

  String languageIdFor(LanguageRole role) {
    switch (role) {
      case LanguageRole.user:
        return userLanguageId;
      case LanguageRole.source:
        return sourceLanguageId;
      case LanguageRole.target:
        return targetLanguageId;
    }
  }

  Map<String, String> toMap() => <String, String>{
        LanguageRole.user.wireName: userLanguageId,
        LanguageRole.source.wireName: sourceLanguageId,
        LanguageRole.target.wireName: targetLanguageId,
      };

  static void _requireNonEmpty(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
  }
}
