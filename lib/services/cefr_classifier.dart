import 'package:flutter/material.dart';

enum CefrLevel { a1, a2, b1, b2, c1, c2, unknown }

class CefrClassifier {
  /// تحديد المستوى بناءً على ترتيب الشيوع وطول الكلمة لأي لغة
  static CefrLevel detectLevel(int frequencyRank, int charLength) {
    if (frequencyRank <= 500 && charLength <= 6) return CefrLevel.a1;
    if (frequencyRank <= 1500) return CefrLevel.a2;
    if (frequencyRank <= 3500) return CefrLevel.b1;
    if (frequencyRank <= 6000) return CefrLevel.b2;
    return CefrLevel.c1;
  }

  /// التسمية المعيارية الدولية الصالحة لجميع اللغات الـ 100
  static String getCode(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return 'A1';
      case CefrLevel.a2: return 'A2';
      case CefrLevel.b1: return 'B1';
      case CefrLevel.b2: return 'B2';
      case CefrLevel.c1: return 'C1';
      case CefrLevel.c2: return 'C2';
      default: return '--';
    }
  }

  /// وصف المستوى باللغة العربية
  static String getLabelAr(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return 'A1 (مبتدئ)';
      case CefrLevel.a2: return 'A2 (أساسي)';
      case CefrLevel.b1: return 'B1 (متوسط)';
      case CefrLevel.b2: return 'B2 (متقدم)';
      case CefrLevel.c1: return 'C1 (احترافي)';
      case CefrLevel.c2: return 'C2 (إتقان تام)';
      default: return 'عام';
    }
  }

  /// التوافق العكسي
  static String getLabel(CefrLevel level) => getLabelAr(level);

  /// ألوان التمييز البصري لكل مستوى
  static Color getLevelColor(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return const Color(0xFF10B981); // زمردي
      case CefrLevel.a2: return const Color(0xFF06B6D4); // سماوي
      case CefrLevel.b1: return const Color(0xFFF59E0B); // كهرماني
      case CefrLevel.b2: return const Color(0xFFF97316); // برتقالي
      case CefrLevel.c1:
      case CefrLevel.c2: return const Color(0xFFEF4444); // أحمر
      default: return const Color(0xFF6B7280);
    }
  }
}
