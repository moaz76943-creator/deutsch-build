import 'package:flutter/material.dart';

/// وحدة التحكم بالخطوط لحماية التشكيل والنصوص المدمجة (RTL/LTR)
class AppTypography {
  
  // حماية التشكيل العربي (الفتحة والضمة والكسرة) من القص
  static const TextHeightBehavior arabicHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  /// توليد نمط خط متوافق مع الحركات
  static TextStyle arabicTextStyle({required double size, required Color color, FontWeight weight = FontWeight.normal}) {
    return TextStyle(
      fontFamily: 'Cairo',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.5, // ارتفاع مرن لمنع تداخل الأسطر
    );
  }
}
