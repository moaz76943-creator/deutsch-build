# Flutter core — keep only what is required for embedding and plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }
-keep class io.flutter.FlutterInjector { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Annotations and attributes needed by reflection / JSON / channels
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Play Integrity (kept for future activation; currently inactive due to offline-first)
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.android.play.core.**

# App-specific: keep only MethodChannel entry points and public API surface
# (broad -keep on entire package was removed to allow full R8 obfuscation of internal logic)
-keep class com.deutschbilarabi.app.AndroidGamificationClockIntegritySource { *; }
-keep class com.deutschbilarabi.app.**$* { *; }

# Aggressive but safe optimizations for release
-repackageclasses ''
-allowaccessmodification
-optimizationpasses 5
-dontusemixedcaseclassnames
-overloadaggressively
-flattenpackagehierarchy

# Strip debug and logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Prevent reflection-based reverse engineering of common entry points
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
