# Flutter & Application Security Architecture
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
