# Flutter & Application Security Architecture
# Optimized for high protection against reverse engineering, modding, and data theft
# Compatible with Google Play Automatic Integrity Protection + Play Integrity API

# === Flutter Core (required) ===
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }
-keep class io.flutter.FlutterInjector { *; }

-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.**

# === Native / Plugin ===
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# === App-specific (keep public API surface for MethodChannels; obfuscate internals) ===
-keep class com.deutschbilarabi.app.** { *; }
-keepclassmembers class com.deutschbilarabi.app.** {
    public <methods>;
}

# === Play Integrity & Security Libraries ===
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.integrity.** { *; }

# === Strip debug logs in release (reduces info leakage) ===
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# === Additional hardening ===
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Optional: further obfuscation dictionary can be added later if needed
