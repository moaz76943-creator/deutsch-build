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

# JNI and optional SQLCipher boundaries. The app keep above already covers
# the Kotlin channel classes; these names stay explicit for the release gate.
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class net.sqlcipher.** { *; }
-keep class net.zetetic.database.** { *; }
-dontwarn net.sqlcipher.**
-dontwarn net.zetetic.database.**
-keep class com.deutschbilarabi.app.AndroidRecordedAudioPlayer { *; }
-keep class com.deutschbilarabi.app.AndroidPronunciationSignalProbe { *; }
-keep class com.deutschbilarabi.app.AndroidPackDatabaseKeyStore { *; }
-keep class com.deutschbilarabi.app.AndroidSecureSessionStorage { *; }
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# Flutter Native Plugins
-keep class com.tundralabs.fluttertts.** { *; }
-dontwarn com.tundralabs.fluttertts.**

-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }
-dontwarn eu.simonbinder.sqlite3_flutter_libs.**
