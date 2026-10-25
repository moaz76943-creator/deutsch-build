# Flutter & Application Security Architecture
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }
-keep class io.flutter.FlutterInjector { *; }

-keepattributes *Annotation*
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.**

# Native sqflite plugin
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Method channels, Keystore wrappers, Play Integrity, and the voice probe.
-keep class com.deutschbilarabi.app.** { *; }

# Optional Play Core
-dontwarn com.google.android.play.core.**
