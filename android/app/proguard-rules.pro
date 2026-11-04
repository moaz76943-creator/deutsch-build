# Flutter core
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }
-keep class io.flutter.FlutterInjector { *; }

# Annotations and attributes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# App-specific native wrappers (Keystore, secure storage, audio)
-keep class com.deutschbilarabi.app.** { *; }

# Play Core (optional, not required)
-dontwarn com.google.android.play.core.**

# Optimization / obfuscation friendly
-repackageclasses
-allowaccessmodification
-optimizationpasses 5
-dontusemixedcaseclassnames

# Preserve line numbers for stack traces (useful for crash reporting)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
