# Flutter & Application Security Architecture
# Optimized for high protection against reverse engineering, modding, and data theft
# Compatible with Google Play Automatic Integrity Protection + Play Integrity API
# Enhanced R8 rules: aggressive obfuscation of internals while preserving Flutter and MethodChannel surfaces

# === Flutter Core (required – do not remove) ===
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }

# الحفاظ على دوال وقواعد البيانات والـ Models
-keepattributes *Annotation*
-dontwarn io.flutter.embedding.**

# تحسين وتقليص استهلاك الذاكرة
-repackageclasses
-allowaccessmodification
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.app.**
-keep class io.flutter.app.** { *; }

-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.**

# === Native / Plugin ===
-keep class com.tekartik.sqflite.** { *; }
-keep class com.deutschbilarabi.app.** { *; }
