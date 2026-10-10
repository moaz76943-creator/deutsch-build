# قواعد الحفاظ على مكتبات التطبيق الأساسية
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# الحفاظ على حزم النطق والتخزين المحلي
-keep class com.tundralabs.fluttertts.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
