import 'dart:convert';
import 'package:flutter/services.dart';

class MultilingualService {
  Future<Map<String, dynamic>> loadLanguagePack(String langCode) async {
    try {
      final String response = await rootBundle.loadString('content/multilingual/generated/$langCode.json');
      final dynamic decoded = json.decode(response);

      if (decoded is Map<String, dynamic>) {
        final List<dynamic> vocabulary = decoded['contentItems'] ?? 
            decoded['vocabulary'] ?? 
            decoded['words'] ?? 
            decoded['terms'] ?? 
            [];

        final List<dynamic> verbs = decoded['verbConjugations'] ?? 
            decoded['verbs'] ?? 
            decoded['conjugations'] ?? 
            [];

        final List<dynamic> grammar = decoded['grammarRules'] ?? 
            decoded['grammar'] ?? 
            decoded['rules'] ?? 
            [];

        return {
          'contentItems': vocabulary,
          'verbConjugations': verbs,
          'grammarRules': grammar,
          ...decoded,
        };
      } else if (decoded is List) {
        return {
          'contentItems': decoded,
          'verbConjugations': [],
          'grammarRules': [],
        };
      }
      return {};
    } catch (e) {
      return {
        'contentItems': [],
        'verbConjugations': [],
        'grammarRules': [],
      };
    }
  }
}
