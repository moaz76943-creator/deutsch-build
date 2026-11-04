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

# Keep annotations and avoid warnings
-keepattributes *Annotation*
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.**
-dontwarn com.google.android.play.core.**

# Native sqflite plugin
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# App-specific security and native bridges (Keystore, session storage, audio)
-keep class com.deutschbilarabi.app.** { *; }
-keep class com.deutschbilarabi.app.AndroidRecordedAudioPlayer { *; }
-keep class com.deutschbilarabi.app.AndroidPackDatabaseKeyStore { *; }
-keep class com.deutschbilarabi.app.AndroidSecureSessionStorage { *; }

# Optimization flags (safe with R8)
-repackageclasses
-allowaccessmodification

# Optional: enable aggressive optimization if tests pass
# -optimizationpasses 5
