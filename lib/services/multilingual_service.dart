import 'dart:convert';
import 'package:flutter/services.dart';

class MultilingualService {
  Future<Map<String, dynamic>> loadLanguagePack(String langCode) async {
    try {
      final String response = await rootBundle.loadString('content/multilingual/generated/$langCode.json');
      return json.decode(response);
    } catch (e) {
      print('Error loading language pack for $langCode: $e');
      return {};
    }
  }
}
